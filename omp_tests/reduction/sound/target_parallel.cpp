#include <stdlib.h>
#include <numeric>
#include <math.h>
#include <cassert>
#include <iostream>
#include <cmath>

void test_target_parallel(){



    // Initialize array
    int A = 0;

    // Computation
    #pragma omp target parallel  reduction(+:A)   defaultmap(tofrom:scalar) 
    {
        A=A+1;
          
    }

    // Validation
    assert( A >= 0 );

    std::cout << "OK" << std::endl ;
}   

int main()
{
    test_target_parallel();
}
