#include <stdlib.h>
#include <numeric>
#include <math.h>
#include <cassert>
#include <iostream>
#include <cmath>

void test_target__teams(){

    // Declare Size of array
    

    // Initialize array
    int A = 0;

    // Computation
    
            
                #pragma omp target   defaultmap(tofrom:scalar) 
            {
            
                #pragma omp teams  reduction(+:A)  
            {
            

            
            {
        
        A=A+1;        
        
            
            }
            
            }
            
            }
    

    // Validation
    
    assert( A >= 0 );
    

    std::cout << "OK" << std::endl ;
}   

int main()
{
    test_target__teams();
}
