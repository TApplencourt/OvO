#include <stdlib.h>
#include <numeric>
#include <math.h>
#include <cassert>
#include <iostream>
#include <cmath>

void test_target__teams__parallel(){



    // Initialize array
    int A = 0;

    // Computation
    #pragma omp target  map(tofrom: A) 
    {
        #pragma omp teams 
        {
            #pragma omp parallel 
            {
                #pragma omp atomic update
                A++;
          
            }
          
        }
          
    }

    // Validation
    assert( A >= 0 );

    std::cout << "OK" << std::endl ;
}   

int main()
{
    test_target__teams__parallel();
}
