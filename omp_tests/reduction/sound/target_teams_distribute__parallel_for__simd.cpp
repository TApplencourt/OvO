#include <stdlib.h>
#include <numeric>
#include <math.h>
#include <cassert>
#include <iostream>
#include <cmath>

void test_target_teams_distribute__parallel_for__simd(){


    // Declare Size of array

    const int L = 10;
    const int M = 10;
    const int N = 10;


    // Initialize array
    int A = 0;

    // Computation
    #pragma omp target teams distribute  reduction(+:A)   defaultmap(tofrom:scalar) 
    for (int i = 0 ; i < L ; i++ )
    {
        #pragma omp parallel for  reduction(+:A)  
        for (int j = 0 ; j < M ; j++ )
        {
            #pragma omp simd  reduction(+:A)  
            for (int k = 0 ; k < N ; k++ )
            {
                A=A+1;
            }
        }
    }

    // Validation
    assert( A == L*M*N );

    std::cout << "OK" << std::endl ;
}   

int main()
{
    test_target_teams_distribute__parallel_for__simd();
}
