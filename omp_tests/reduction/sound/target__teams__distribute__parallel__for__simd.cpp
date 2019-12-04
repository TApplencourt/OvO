#include <stdlib.h>
#include <numeric>
#include <math.h>
#include <cassert>
#include <iostream>
#include <cmath>

void test_target__teams__distribute__parallel__for__simd(){


    // Declare Size of array

    const int L = 10;
    const int M = 10;
    const int N = 10;


    // Initialize array
    int A = 0;

    // Computation
    #pragma omp target   defaultmap(tofrom:scalar) 
    {
        #pragma omp teams  reduction(+:A)  
        {
            #pragma omp distribute  
            for (int i = 0 ; i < L ; i++ )
            {
                #pragma omp parallel  reduction(+:A)  
                {
                    #pragma omp for  
                    for (int j = 0 ; j < M ; j++ )
                    {
                        #pragma omp simd  reduction(+:A)  
                        for (int k = 0 ; k < N ; k++ )
                        {
                            A=A+1;
          
                        }
          
                    }
                }
          
            }
        }
    }

    // Validation
    assert( A == L*M*N );

    std::cout << "OK" << std::endl ;
}   

int main()
{
    test_target__teams__distribute__parallel__for__simd();
}
