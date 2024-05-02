# Spindler-c V 1.0.0
The c version of the spindler (https://github.com/ruggero-valli/spindler) package, used to compute the long-term orbital evolution of a binary interacting with a circumbinary disk.
The aim of this library is to facilitate the integration of the spindler functionalities
into c or Fortran-based codes.

Based on Valli et al. 2024 (in prep)

## Requirements:
Spindler-c requires a working installation of librinterplate by Robert Izzard (https://gitlab.com/rob.izzard/librinterpolate)

## Installation:
```bash
git clone https://github.com/ruggero-valli/spindler-c.git
cd spindler-c
make
```
You can test wether the installation was succesfull by running
```bash
make test
```
If the last line of the output is `OK`, then the installation was succesfull and the program is working.

## Description
spindler provides three alternative models of binary-disk interaction
- **Siwek23**: based on the simulations in
   - Siwek et al. 2023 (2023MNRAS.518.5059S)
   - Siwek et al. 2023 (2023MNRAS.522.2707S)
    
    It is defined for eccentricity between 0 and 0.8, and mass ratio between 0.1
    and 1.
- **DD21**: based on the simulations in
    - D'Orazio and Duffell 2021 (2021ApJ...914L..21D)
    
    It is defined for eccentricity between 0 and 0.8, and mass ratio equal to 1.
- **Zrake21**: based on the simulations in
    - Zrake et al. 2021 (2021ApJ...909L..13Z)
    
    It is defined for eccentricity between 0 and 0.8, and mass ratio equal to 1.

## Documentation of the python version
https://spindler.readthedocs.io/

The spindler-c is similar to the corresponding python package. It provides
functions to compute the derivatives of the orbital parameters, exactly as in
the python version.

It doens't include the functionality to integrate these derivatives.

## Example usage

```c
#include <stdio.h>
#include <stdlib.h>
#include "spindler.h"

int main(){

    // Choose the model. It must be either "Siwek23", "Zrake21" or "DD21".
    char* model_name = "Siwek23";

    // Initialize the library
    struct spindler_data_t* spindler_data = calloc(1, sizeof(struct spindler_data_t));
    int err;
    err = spindler_init(model_name, spindler_data);
    if (err != SPINDLER_NO_ERROR){
        return 1;
    }


    // Pick a mass ration and an eccentricity
    double q=0.5, e=0.5;

    // Compute their derivatives
    double Dq, De, Da, DE, DJ;
    Dq = spindler_get_Dq(q, e, spindler_data);
    De = spindler_get_De(q, e, spindler_data);
    Da = spindler_get_Da(q, e, spindler_data);
    DE = spindler_get_DE(q, e, spindler_data);
    DJ = spindler_get_DJ(q, e, spindler_data);

    // Print the results
    printf("Dq: %lf, De: %lf, Da: %lf, DE: %lf, DJ: %lf\n", Dq, De, Da, DE, DJ);

    // Free the allocated structures
    spindler_free_data(spindler_data);
    free(spindler_data);
    return 0;
}
```