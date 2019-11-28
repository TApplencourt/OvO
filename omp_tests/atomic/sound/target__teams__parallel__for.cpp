#include <stdlib.h>
#include <numeric>
#include <math.h>
#include <cassert>
#include <iostream>
#include <cmath>

void test_target__teams__parallel__for(){

    // Declare Size of Loop
    
    const int L = 10;

    // Initialize array
    int A = 0;

    // Computation
    
            
                #pragma omp target  map(tofrom: A) 
            {
            
                #pragma omp teams 
            {
            
                #pragma omp parallel 
            {
            

            
                #pragma omp for 
                for (int i = 0 ; i < L ; i++ )
            
            {
        
        #pragma omp atomic update
        A++;
        
        
            
            }
            
            }
            
            }
            
            }
    

    // Validation
    
    assert( A >= 0 );
    

    std::cout << "OK" << std::endl ;
}   

int main()
{
    test_target__teams__parallel__for();
}
