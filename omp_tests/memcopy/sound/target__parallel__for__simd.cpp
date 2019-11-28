#include <stdlib.h>
#include <numeric>
#include <math.h>
#include <cassert>
#include <iostream>
#include <cmath>

void test_target__parallel__for__simd(){

    // Declare Size of array
    
    const int L = 10;
    const int M = 10;

    // Initialize array
    double A[L][M];
    double B[L][M] = { 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99 };

    // Computation
    
        
           #pragma omp target  map(from: A[0:L][0:M]) map(to: B[0:L][0:M]) 
            {
        
           #pragma omp parallel 
            {
        

        
            #pragma omp for 
            for (int i = 0 ; i < L ; i++ )
        
        {
    
        

        
            #pragma omp simd 
            for (int j = 0 ; j < M ; j++ )
        
        {
    
        
    A[i][j] = B[i][j];

    
        
        }
        
        }
        
        }
    
        
        }
    

    // Validation
    
        
        for (int i = 0 ; i < L ; i++ )
        
        {
    
        
        for (int j = 0 ; j < M ; j++ )
        
        {
    
    assert( std::fabs( A[i][j] - B[i][j]) < 1E-9 );
        }
        }
    std::cout << "OK" << std::endl ;
}

int main()
{
    test_target__parallel__for__simd();
}
