#include <stdlib.h>
#include <numeric>
#include <math.h>
#include <cassert>
#include <iostream>
#include <cmath>

void test_target_teams__parallel(){



    // Initialize array
    int A = 0;

    // Computation
    #pragma omp target teams  map(tofrom: A) 
    {
        #pragma omp parallel 
        {
            #pragma omp atomic update
            A++;
          
        }
          
    }

    // Validation
    assert( A >= 0 );

    std::cout << "OK" << std::endl ;
}   

int main()
{
    test_target_teams__parallel();
}
