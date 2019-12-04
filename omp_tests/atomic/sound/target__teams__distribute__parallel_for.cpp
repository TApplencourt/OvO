#include <stdlib.h>
#include <numeric>
#include <math.h>
#include <cassert>
#include <iostream>
#include <cmath>

void test_target__teams__distribute__parallel_for(){


    // Declare Size of Loop

    const int L = 10;

    const int M = 10;


    // Initialize array
    int A = 0;

    // Computation
    #pragma omp target  map(tofrom: A) 
    {
        #pragma omp teams 
        {
            #pragma omp distribute
            for (int i = 0 ; i < L ; i++ )
            {
                #pragma omp parallel for
                for (int j = 0 ; j < M ; j++ )
                {
                    #pragma omp atomic update
                    A++;
          
                }
          
            }
        }
    }

    // Validation
    assert( A == L*M );

    std::cout << "OK" << std::endl ;
}   

int main()
{
    test_target__teams__distribute__parallel_for();
}
