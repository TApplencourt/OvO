#include <stdlib.h>
#include <numeric>
#include <math.h>
#include <cassert>
#include <iostream>
#include <cmath>

void test_target_teams_distribute_parallel_for__simd(){


    // Declare Size of array

    const int L = 10;
    const int M = 10;


    // Initialize array
    int A = 0;

    // Computation
    #pragma omp target teams distribute parallel for  reduction(+:A)   defaultmap(tofrom:scalar) 
    for (int i = 0 ; i < L ; i++ )
    {
        #pragma omp simd  reduction(+:A)  
        for (int j = 0 ; j < M ; j++ )
        {
            A=A+1;
        }
    }

    // Validation
    assert( A == L*M );

    std::cout << "OK" << std::endl ;
}   

int main()
{
    test_target_teams_distribute_parallel_for__simd();
}
