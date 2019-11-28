#include <stdlib.h>
#include <numeric>
#include <math.h>
#include <cassert>
#include <iostream>
#include <cmath>

void test_target__teams__parallel__for(){

    // Declare Size of array
    
    const int L = 10;

    // Initialize array
    int A = 0;

    // Computation
    
            
                #pragma omp target   defaultmap(tofrom:scalar) 
            {
            
                #pragma omp teams  reduction(+:A)  
            {
            
                #pragma omp parallel  reduction(+:A)  
            {
            

            
                #pragma omp for  
                for (int i = 0 ; i < L ; i++ )
            
            {
        
        A=A+1;        
        
            
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
