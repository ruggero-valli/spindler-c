###########################################################
# meson build file for spinlder-c
#
# based on the binary_c meson.build
#
# (c) Robert Izzard 14/03/2024
#
# Please see and abide by the LICENCE!
#
############################################################

project(
    'splinder-c','c',
    default_options : [
        # c_std and cpp_std are set below
        'b_asneeded=false', # required on some platforms
    ],
    version : '1.0', # should match the version in spindler.h
)

############################################################
# get operating system information
os = host_machine.system()

############################################################
# basic system requirements
#
system_requirements = {
                            'meson':'--version',
                            'ninja':'--version',
                            'head':'--version',
                            'sed':'--version',
                            'perl':'--version',
                            'cp':'--version',
                            'ln':'--version',
                            'grep':'--version',
                            'gawk':'--version',
                            'wc':'--version',
                            'tr':'--version',
                            'tail':'--version',
                            'bash':'--version',
                            'sh':'',
                            'date':'--version',
                            'pkg-config':'--version',
                            'which':'',
                            'ls':'--version',
			                'ld':'--version',
                            'env':'--version',
                            'rm':'--version',
                        }

############################################################
# get paths to programs
#
program_paths = {}
foreach cmd, version_args : system_requirements
    _program = find_program(cmd, required:true)
    if _program.found()
        _program_path = _program.path()
        if version_args != ''
            _program_version = run_command('meson/versionof.sh',
                                           _program_path,
                                           version_args,
                                           check:true).stdout().strip()
            message(cmd + ' version "' + _program_version + '"')
        endif
        # save in dictionary for later
        program_paths += { cmd : _program_path }
    else
        message(cmd + 'not found : it is a requirement')
        exit
    endif
endforeach

############################################################
# meson's process id
#
pid = run_command('meson/parent_pid.sh',check:true).stdout().strip()
message('Meson process ID ' + pid)

############################################################
# compiler object
#
compiler = meson.get_compiler('c')
message('compiler ' + compiler.get_id())

############################################################
# hence C (and C++) standards for the build.
# These depend on the compiler, but we require gnu20x.
#
our_compiler_version = compiler.version()
if compiler.get_id() == 'clang'
  if our_compiler_version.version_compare('<18')
      # clang <= 17.x
      c_std = 'gnu2x'
  else
      # clang 18+
      c_std = 'gnu23'
  endif
elif compiler.get_id() == 'gcc'
    if our_compiler_version.version_compare('<9.0')
      c_std = 'gnu18'
    else
      c_std = 'gnu2x' # or gnu23 in latest
    endif
elif compiler.get_id() == 'intel'
   # Intel supports only up to gnu99
   c_std = 'gnu99'
else
   warning('Unknown compiler ' + compiler.get_id() + ' : assuming c99')
   c_std = 'c99'
endif
language_standards_flags = [ '-std=' + c_std ]
message('Set C language standard (std) = ' + c_std)

############################################################
# C compiler flags
#
cflags = language_standards_flags
executable_build_flags = [ ]

############################################################
# operating system flags
#
cflags += [
    '-DOPERATING_SYSTEM=' + os
    ]
if os == 'linux'
    # Linux system
    cflags += [
        '-DLINUX',
        '-DPOSIX',
        '-DLARGEFILE_SOURCE'
    ]
    unix = true
    posix = true
    ld_library_path_prefix = ''
elif os == 'darwin'
    # darwin (MacOSX)
    cflags += [
        '-DDARWIN',
        '-DPOSIX',
        '-D_XOPEN_SOURCE',
    ]
    if compiler.get_id() == 'clang'
        # suppress floating point warnings
        cflags += [
            '-Wno-unsupported-floating-point-opt'
        ]
    endif
    unix = true
    posix = true
    ld_library_path_prefix = 'DY'
elif os == 'windows'
    # windows
    cflags += [
        '-DWINDOWS',
    ]
    unix = false
    posix = false
    ld_library_path_prefix = ''
else
    cflags += [
        '-DUNKNOWN_OPERATING_SYSTEM'
    ]
    unix = false
    posix = false
    ld_library_path_prefix = ''
endif


############################################################
# output various environment variables to the meson.log
# and set them in a dictoinary
#
envvars = {}
foreach var : [
    'PATH',
    'LIBRARY_PATH', # Linux
    'LIBPATH', # LIBRARY_PATH in Windows
    ld_library_path_prefix + 'LD_LIBRARY_PATH' # OSX
]
    cmd = run_command(program_paths['sh'], '-c', 'echo $' + var,check: false)
    envvar_string = cmd.stdout().strip()
    message(var + '=' + envvar_string)
    envvars += { var : envvar_string }
endforeach

############################################################
# wait for exit (after ninja is set up) and then run a
# script to make compile_commands.json with absolute
# paths in it (using the make_compile_commands_json.sh
# script)
#
run_command(program_paths['bash'],
            'meson/background.sh',
            'meson/wait_for_exit.sh',
            pid,
            'meson/make_compile_commands_json.sh',
            '</dev/null',
            '>/dev/null',
            '2>/dev/null',
            check:true
           )

if os == 'darwin'
   run_command(program_paths['bash'],
	           'meson/background.sh',
               'meson/wait_for_exit.sh',
               pid,
               'meson/osx_clean_build_ninja.sh',
               '</dev/null',
               '>/dev/null',
               '2>/dev/null',
               check:true
           )
endif

############################################################
# variables for later
#
dependencies = []
required_libraries = {}
shared_lib_args = []

############################################################
# require Meson 0.56.0 or later
#
find_program('meson',
             version: '>=0.56')

############################################################
# require Ninja 1.10.0 or later
#
find_program('ninja',
             version: '>=1.10.0')

############################################################
# check binutils version
binutils_version = run_command('meson/versionof.sh',
                               'ld --version',
                               check:true).stdout().strip()
message('binutils version: ' + binutils_version)

############################################################
# Reject buggy Perl versions
#
buggy_perls = [ '5.31.6' ]
perl = find_program('perl')
perl_version = run_command(program_paths['perl'],
                           '-e',
                           'print substr($^V,1)',check:true).stdout().strip()
if perl_version == ''
    error('Your Perl version is empty : is Perl working?')
endif
message('Perl is version ' + perl_version)
foreach buggy_perl_version : buggy_perls
    if perl_version.version_compare(buggy_perl_version)
        error('Your Perl version ' + perl_version + ' is buggy and hence unsupported: please upgrade!')
    endif
endforeach

############################################################
# compiler and linker
#
# Meson uses cmd_array() for the compiler
cc_command = ' '.join(compiler.cmd_array())
cc_quoted = '-DCC="' + cc_command + '"'
if cc_command.contains('scan-build')
    scanbuild = true
    message('Build for scan-build')
else
    scanbuild = false
endif
compiler_id = '-DCOMPILER_ID="' + compiler.get_id() + '"'
# But nothing for the linker, so instead default to the compiler
ld_quoted = '-DLD="' + ' '.join(compiler.cmd_array()) + '"'
linker_id = '-DLINKER_ID="' + compiler.get_linker_id() + '"'

############################################################
# exit if compiler is buggy/unsupported
#
if compiler.get_id() == 'gcc'
    message('GCC version is ' + our_compiler_version)

elif compiler.get_id() == 'clang'
    _clang_version = compiler.run('''
#include <stdio.h>
int main(void)
{
    printf("%d\n",(int)__clang_major__);
    return 0;
}
''')
    message('return code ' + _clang_version.returncode().to_string())
    if _clang_version.compiled() == true
        if _clang_version.returncode() == 0
            clang_version = _clang_version.stdout().to_int()
        else
            error('Could not determine clang version')
        endif
    else
        error('Could not build clang version check code')
    endif
    message('Clang version is ' + clang_version.to_string())
endif

############################################################
# System information
#
############################################################

############################################################
# get spindler root and src locations
#
spindler_dir = meson.current_source_dir()
spindler_src = spindler_dir + '/src'
spindler_inc = spindler_dir + '/include'

############################################################
# get spindler version (from spindler.h)
#
spindler_version = compiler.run('''
#include <stdio.h>
#include "''' + spindler_dir + '''/include/spindler.h"
int main(int argc,char **argv)
{
        fprintf(stdout,"%s",SPINDLER_VERSION);
        return 0;
}''').stdout().strip()

############################################################
# the spindler version should be the same as the project
# version: exit if not!
#
if spindler_version != meson.project_version()
    error('spindler_version ' + spindler_version + \
          ' and meson.project_version ' + meson.project_version() + \
          ' are not the same : they should be!')
else
    message('spindler version is ' + spindler_version)
endif

############################################################
# SVN and git information
#
git_revision = run_command(program_paths['sh'],'-c','meson/git_revision.sh',check:true).stdout().strip()
git_url = run_command(program_paths['sh'],'-c','meson/git_url.sh',check:true).stdout().strip()
git_branch = run_command(program_paths['sh'],'-c','meson/git_branch.sh',check:true).stdout().strip()

############################################################
# default include and library search directories
#
incdirs = [
    '.',
    './include',
]
libdirs = [
    spindler_src
]
absolute_incdirs = libdirs

############################################################
# cflags required for generic builds and other builds
#
_other_cflags = [
    '-std=' + c_std, 
    '-fstrict-aliasing', # enforce strict aliasing
    '-Wstrict-aliasing', # and enforce warnings if we break it
    '-g', # required for profiling,
    '-Wpedantic',
    '-Wshadow',
    '-fstack-protector-all', # stack smashing checks (slows runtime)
    '-rdynamic',
]
if scanbuild == false
    _other_cflags += [
        '-fsignaling-nans', # probably required
    ]
endif

# clang-specific
if compiler.get_id() == 'clang'
    _other_cflags += [
        # annoying warnings -Wpedantic gives
        '-Wno-newline-eof',
    ]
endif

foreach cflag : _other_cflags
    if compiler.has_argument(cflag)
        cflags += [ cflag ]
    endif
endforeach

############################################################
# C flags that are non-generic, i.e. machine-specific.
#
if get_option('generic') == false
    _non_generic_cflags = [
        # put list here
    ]
    foreach cflag : _non_generic_cflags
        __cflag = '-m' + cflag
        if compiler.has_argument( __cflag )
            cflags += [ __cflag ]
        endif
    endforeach
endif


if get_option('gprof') == true
    # setup for gprof
    cflags += [ '-g', '-pg', '-DGPROF' ]
endif

if get_option('valgrind') == true
    # Some new instruction sets, e.g. SSE4 and AVX512, are not
    # yet compatible with Valgrind. Disable these.
    # details: https://valgrind.org/info/platforms.html
    _instruction_sets = [
        'avx',
        'sse4',
    ]
    cflags += [ '-DVALGRIND' ]
    foreach cflag : _instruction_sets
        __cflag = '-mno-' + cflag
        if compiler.has_argument( __cflag )
            cflags += [ __cflag ]
        endif
    endforeach
    # flags to give more debugging output for valgrind (or gdb)
    _gflags = [
        'gdb3',
        'describe-dies',
        'pubnames',
        'dwarf-4',
        '3'
    ]

    if get_option('b_lto') == false
        _gflags += [
            # valgrind cannot handle split-dwarf with dwarf-5, but can
            # do split-dwarf with dwarf-4.
            #
            # current runtimes for valgrind with 2 systems:
            #
            # dwarf-5 without split-dwarf : 29.2s
            # dwarf-4 with split-dwarf : 18.62s
            #
            # so I'd recommend split-dwarf with dwarf-4
            #
            # Note: this will be disabled if link-time
            #       optimization is on
            'split-dwarf',
        ]
    endif

    foreach cflag : _gflags
        __cflag = '-g' + cflag
        if compiler.has_argument( __cflag )
            cflags += [ __cflag ]
        endif
    endforeach
    _fflags = [
        'var-tracking',
        'var-tracking-assignments',
    ]
    foreach cflag : _fflags
        __cflag = '-f' + cflag
        if compiler.has_argument( __cflag )
            cflags += [ __cflag ]
        endif
    endforeach
endif

############################################################
# Clang's address sanitizer
# https://clang.llvm.org/docs/AddressSanitizer.html
#
if get_option('b_sanitize') == 'address'
    warning('Using settings for address sanitizer: this is experimental and likely buggy!')
    if compiler.get_id() == 'clang'
        # clang-specific
        required_libraries += { 'asan' : '' }
        shared_lib_args += ['-shared-libasan']
    endif
    if compiler.get_id() == 'gcc'
        # gcc-specific
    endif
endif

############################################################
# optional C flags
#
optional_flags = [ ]

# generic build
if get_option('generic') == true
    optional_flags += [
        '-mtune=generic',
    ]
    message('Using generic build option')
else
    optional_flags += [
        '-march=native',
        '-mtune=native',
    ]
    message('Using native build option')
endif

# accurate mathematical options
if get_option('accurate') == true
    optional_flags += [
        '-frounding-math',
        '-fno-stack-protector',
        '-ffloat-store',
    ]
else
    optional_flags += [
        ############################################################
        # these are what -ffast-math does without -funsafe-math-optimizations
        #
        # Note: we disable some of them
        '-fno-associative-math',
        '-fno-math-errno',
        '-ffinite-math-only', # not good
        '-fno-rounding-math',
        '-fcx-limited-range',
        # never allow unsafe math optimizations
        '-fno-unsafe-math-optimizations',
        ############################################################
    ]
    if scanbuild == false
        optional_flags += [
            '-fno-signaling-nans', # should be off : nan-signalling is required
            '-fexcess-precision=fast',
            ]
    endif
endif

# note:
# -fno-finite-math-only and -fsignaling-nans cause
# library-naming problems with gcc 10.3

optional_flags += [
    '-fno-finite-math-only',
    '-fasynchronous-unwind-tables',
#    '-fvisibility=hidden', # do not hide library functions
    '-rdynamic',
    '-export-dynamic',
]

# flags that should not be combined with debugging
if not get_option('buildtype').startswith('debug') and \
   get_option('valgrind') == false and \
   get_option('address_sanitizer') == false
    optional_flags += [
        '-fomit-frame-pointer', # not good for debugging?
    ]
endif

############################################################
# debug C flags
if get_option('buildtype').startswith('debug')
    optional_flags += [
        '-rdynamic',
        '-O0',
        '-g',
        #'-fpack-struct=1', # breaks shared library support
    ]
endif

############################################################
# Now go through the optional_flags, and use those that
# are supported by the compiler.
#
foreach _flag : optional_flags
    if compiler.has_argument(_flag)
        cflags += _flag
    endif
endforeach


############################################################
# per-compiler options
#
if compiler.get_id() == 'clang'
    # clang-speific flags
    foreach _flag : [ '-fbracket-depth=512' ]
        if compiler.has_argument(_flag)
            cflags += _flag
        else
            error('clang requires ' + _flag + ' to build, but this flag is not available')
        endif
    endforeach
    
    # for some reason we require an extra fPIC
    # when building the executable *only*
    executable_build_flags += '-fPIC'
else
    # gcc-specific flags
    cflags += []
endif

############################################################
# set spindler src directory in cflags
cflags += '-DSPINDLER_SRC="' + spindler_src + '"'

############################################################
# get source file list
src_root_sourcefiles = run_command('meson/source_files.sh','./src',check:false).stdout().strip().split('\n')

############################################################
# set link-time optimization
if get_option('b_lto') == true
    cflags += '-DLTO'
endif

############################################################
# set link-time optimization in cflags
cflags += '-DPGO_' + get_option('b_pgo')

############################################################
# version control options
#
if git_revision != ''
    _flag = '-DSPINDLER_GIT_REVISION="' + git_revision + '"'
    cflags += _flag
endif

if git_url != ''
    _flag = '-DSPINDLER_GIT_URL="' + git_url + '"'
    cflags += _flag
endif

if git_branch != ''
    _flag = '-DSPINDLER_GIT_BRANCH="' + git_branch + '"'
    cflags += _flag
endif

############################################################
# libraries
#
required_libraries += {
                           'c' : '',
                           'm' : '',
                           'rinterpolate' : 'rinterpolate-config',
                       }
libs = [] # libraries list sent to compiler

foreach x : ['generic','allow_libs']
    if get_option(x) == true
        message('Check ' + x + ' on')
    else
        message('Check ' + x + ' off')
    endif
endforeach

if get_option('generic') == false or \
   get_option('allow_libs') == true
    foreach libname, libconfigure : required_libraries
        message('Check for library ' + libname)
        _dep = compiler.find_library(libname,
                                     required:false)
        if _dep.found()
            # found the library, add it to the cflags and libs lists
            cflags += '-D__HAVE_LIB' + libname.to_upper() + '__'
            libs += '-l' + libname

            if libconfigure != ''
                # try libname-config for extra flags
                _config_cmd = libconfigure
                _config_program = find_program(_config_cmd, required : false)

                if _config_program.found()
                    # found *-config program
                    _config_program_path = _config_program.path()

                    # add library search paths
                    _config_libdirs = run_command(_config_program_path,'--libs',check:true).stdout().strip().split(' ')
                    foreach _config_libdir : _config_libdirs
                        if _config_libdir.startswith('-L')
                            libdirs += _config_libdir.strip().split('-L')[1]
                            message('ADD LIB ' + ' '.join(libdirs))
                        endif
                    endforeach

                    # add include search paths
                    _config_cflags = run_command(_config_program_path,'--cflags',check:true).stdout().strip().split(' ')
                    foreach _config_cflag : _config_cflags
                        if _config_cflag.startswith('-I')
                            _incdir = _config_cflag.strip().split('-I')[1]
                            incdirs += _incdir
                            absolute_incdirs += _incdir
                        endif
                    endforeach

                    # add include path from prefix
                    _prefix = run_command(_config_program_path,'--prefix',check:true).stdout().strip()
                    if _prefix != ''
                        incdirs += _prefix + '/include'
                    endif
                endif
            endif
        else
            error(libname + ' not found')
        endif
    endforeach
endif

############################################################
# make libdirs unique
#
if true
    _libdirsdict = {}
    _newlibdirs = []
    foreach _libdir : libdirs
        if _libdirsdict.has_key(_libdir) == false
            _newlibdirs += _libdir
            _libdirsdict += { _libdir : '1' }
        endif
    endforeach
    libdirs = _newlibdirs
endif

############################################################
# make incdirs unique
#
if true
    _incdirsdict = {}
    _newincdirs = []
    foreach _incdir : incdirs
        if _incdirsdict.has_key(_incdir) == false
            _newincdirs += _incdir
            _incdirsdict += { _incdir : '1' }
        endif
    endforeach
    incdirs = _newincdirs
endif

############################################################
# make absolute_incdirs unique
#
if true
    _incdirsdict = {}
    _newincdirs = []
    foreach _incdir : absolute_incdirs
        if _incdirsdict.has_key(_incdir) == false
            _newincdirs += _incdir
            _incdirsdict += { _incdir : '1' }
        endif
    endforeach
    absolute_incdirs = _newincdirs
endif

############################################################
# make cflags unique
#
if true
    _cflagsdict = {}
    _newcflags = []
    foreach _cflag : cflags
        if _cflagsdict.has_key(_cflag) == false
            _newcflags += _cflag
            _cflagsdict += { _cflag : '1' }
        endif
    endforeach
    cflags = _newcflags
endif

############################################################
# make libs unique
#
if true
    _libsdict = {}
    _newlibs = []
    foreach _cflag : libs
        if _libsdict.has_key(_cflag) == false
            _newlibs += _cflag
            _libsdict += { _cflag : '1' }
        endif
    endforeach
    libs = _newlibs
endif

############################################################
# source files
#
c_sourcefiles = run_command('meson/c_sourcefiles.sh',check:true).stdout().strip().split('\n')
h_sourcefiles = run_command('meson/h_sourcefiles.sh',check:true).stdout().strip().split('\n')

############################################################
# extra quoted flags to pass into spindler
#
cflags_with_O = cflags + [ '-O' + get_option('optimization') ] # cflags with -O<n>
cflags_quoted = ' '.join(cflags_with_O) # turn to string
cflags_quoted = ''.join(cflags_quoted.split('"'))  # remove "
cflags_quoted = '-DCFLAGS=' + ''.join(['"', cflags_quoted , '"']) # surround in " ... "
message('CFLAGS=' + cflags_quoted)
incdirs_quoted = '-DINCDIRS=' + ''.join(['"-I',' -I'.join(absolute_incdirs),'"']) # make -I... -I...
message('INCDIRS=' + incdirs_quoted)
incdirs_quoted = '_slash_'.join(incdirs_quoted.split('/')) # deslash (convert / to _slash_)
libdirs_quoted = '-DLIBDIRS=' + ''.join(['"-L', ' -L'.join(libdirs),'"']) # make -.L.. -L...
message('LIBDIRS=' + libdirs_quoted)
message('abs ' + ' '.join(libdirs))
libdirs_quoted = '_slash_'.join(libdirs_quoted.split('/')) # deslash
libs_quoted = '-DLIBS=' + ''.join(['"', ' '.join(libs),'"'])
libs_quoted = '_slash_'.join(libs_quoted.split('/'))

# hence a quoted version of the cflags
quoted_cflags_list = [
    cflags_quoted,
    compiler_id,
    cc_quoted,
    incdirs_quoted,
    ld_quoted,
    libdirs_quoted,
    libs_quoted,
]

############################################################
# make list of libraries for the linker
linker_args = []
foreach _lib : libdirs
    linker_args += '-L' + _lib
endforeach
#if os == 'darwin'
#    linker_args += '-no_warning_for_no_symbols'
#endif
message('Linker args: ' +  ' '.join(linker_args))

############################################################
# compiler warning flags
############################################################
warn_flags = []
foreach _arg : [
    'all',
    'extra',
    'format',
    'no-nonnull',
    'no-nonnull-compare',
    'strict-prototypes',
    'format-signedness'
]
    _warn_arg = '-W' + _arg
    if compiler.has_argument(_warn_arg)
        warn_flags += _warn_arg
    endif
endforeach
cflags += warn_flags

############################################################
# append library locations to cflags
# (note: clang does not support this syntax)
#
if compiler.get_id() != 'clang'
    foreach libdir : libdirs
        _l = '-L' + libdir
        cflags += _l
    endforeach
endif

############################################################
# add Meson project name and version
cflags += [
  '-DSPINDLER_MESON_PROJECT_NAME=' + meson.project_name(),
  '-DSPINDLER_MESON_PROJECT_VERSION=' + meson.project_version(),
]

############################################################
# make gtags database
#
gtags = find_program('gtags',required:false)
if gtags.found()
    message('Making ggtags database with gtags version ' + run_command('meson/versionof.sh',gtags.path(),version_args,check:true).stdout().strip())
    run_command('meson/ggtags-create-tags.sh',check:true)
else
    message('gtags not found but may not be required')
endif

############################################################
#
# make shared library
#
spindler_shared_library = shared_library(
    get_option('libname'),
    override_options : [
    		     'cstd='+c_std,
		     ],
    build_by_default : false,
    install: true,
    include_directories: include_directories(incdirs),
    dependencies : [
        dependencies
    ],
    sources : [ run_command('meson/source_files.sh',spindler_src,check:false).stdout().strip().split('\n') ],
    c_args : [
        cflags,
        quoted_cflags_list,
    ],
    link_args : [
        libs,
    ] + shared_lib_args,
    link_with: [
    ],
)

############################################################
#
# "install" shared library in local lib/ directory
# (as make does) ... probably shouldn't do this, but it's
# what spindler's developers expect.
#
spindler_install_legacy = custom_target(
    'spindler_install_legacy',
    build_by_default : true,
    output: [ 'spindler_install_legacy' ],
    command : ['cp','libspindler.so','../lib/'],
    depends: [
        spindler_shared_library
    ]
)

############################################################
#
# test executable
#
test_spindler = executable(
    'test_spindler',
    build_by_default : false,
    install : false,
    override_options : [
    	'cstd='+c_std,
	],
    sources : [
        'tests/test_spindler.c'
    ],
    include_directories: [
        include_directories(incdirs),
    ],
    dependencies: [
        dependencies ,
        declare_dependency(link_with : spindler_shared_library),
    ],
    c_args : [
        cflags,
        quoted_cflags_list,
        executable_build_flags,
    ],
    link_args : [
        [
        ] + libs + ['-lspindler']
    ],
    link_with: [
    ],
)
