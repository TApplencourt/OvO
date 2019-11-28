#include <stdlib.h>
#include <numeric>
#include <math.h>
#include <cassert>
#include <iostream>
#include <cmath>

void test_target__parallel_for(){

    // Declare Size of Loop
    
    const int L = 10;

    // Initialize array
    int A = 0;

    // Computation
    
            
                #pragma omp target  map(tofrom: A) 
            {
            

            
                #pragma omp parallel for 
                for (int i = 0 ; i < L ; i++ )
            
            {
        
        #pragma omp atomic update
        A++;
        
        
            
            }
            
            }
    

    // Validation
    
    assert( A == L );
    

    std::cout << "OK" << std::endl ;
}   

int main()
{
    test_target__parallel_for();
}
