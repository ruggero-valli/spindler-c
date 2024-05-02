#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <math.h>
#include "spindler.h"

#define ASSERT(condition) \
    do { \
        if (!(condition)) { \
            printf("Assertion failed: %s, file: %s, line: %d\n", #condition, __FILE__, __LINE__); \
            exit(EXIT_FAILURE); \
        } \
    } while(0)

#define TOLERANCE 1e-6

void test_spindler_init() {
    struct spindler_data_t spindler_data;
    int result = spindler_init("nonexistent_model", &spindler_data);
    ASSERT(result == SPINDLER_DIR_NOT_FOUND);
    printf("spindler_init test passed.\n");
}

void test_spindler_Siwek23() {
    // Test against "Siwek23"
    struct spindler_data_t spindler_data;
    int err;
    double De, Dq, Da;
    double e[3] = {0}, q[3] = {0};
    err = spindler_init("Siwek23", &spindler_data);
    ASSERT(err == SPINDLER_NO_ERROR);

    // De vs Dq
    q[0]=0.2; q[1]=0.4; q[2]=1.0;
    e[0]=0.8; e[1]=0.3; e[2]=0.2;
    for (int i=0; i<3; i++){
        De = spindler_get_De(q[i], e[i], &spindler_data);
        Dq = spindler_get_Dq(q[i], e[i], &spindler_data);
        ASSERT(fabs(De) > Dq);
    }

    // Dq positive
    q[0]=0.2; q[1]=0.4; q[2]=0.6;
    e[0]=0.1; e[1]=0.3; e[2]=0.5;
    for (int i=0; i<3; i++){
        Dq = spindler_get_Dq(q[i], e[i], &spindler_data);
        ASSERT(Dq > 0);
    }

    e[0] = 0.48;
    q[0] = 1.0;
    Da = spindler_get_Da(q[0], e[0], &spindler_data);
    ASSERT(Da < 0);

    e[0] = 0.05;
    q[0] = 1.0;
    Da = spindler_get_Da(q[0], e[0], &spindler_data);
    ASSERT(Da > 0);

    spindler_free_data(&spindler_data);
    printf("spindler_Siwek23 test passed.\n");
}

void test_spindler_Zrake21() {
    // Test against "DD21"
    struct spindler_data_t spindler_data;
    int err;
    double De, Dq, Da;
    double e[3] = {0}, q[3] = {0};
    err = spindler_init("Zrake21", &spindler_data);
    ASSERT(err == SPINDLER_NO_ERROR);


    spindler_free_data(&spindler_data);
    printf("spindler_Zrake21 test passed.\n");
}

void test_spindler_DD21() {
    // Test against "DD21"
    struct spindler_data_t spindler_data;
    int err;
    err = spindler_init("DD21", &spindler_data);
    ASSERT(err == SPINDLER_NO_ERROR);

    
    spindler_free_data(&spindler_data);
    printf("spindler_DD21 test passed.\n");
}

int main() {
    test_spindler_init();
    test_spindler_Siwek23();
    test_spindler_Zrake21();
    test_spindler_DD21();

    return 0;
}
