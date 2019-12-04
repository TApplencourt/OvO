#include <stdlib.h>
#include <numeric>
#include <math.h>
#include <cassert>
#include <iostream>
#include <cmath>

void test_target__teams_distribute__parallel(){


    // Declare Size of Loop

    const int L = 10;


    // Initialize array
    int A = 0;

    // Computation
    #pragma omp target  map(tofrom: A) 
    {
        #pragma omp teams distribute
        for (int i = 0 ; i < L ; i++ )
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
    test_target__teams_distribute__parallel();
}
