#include <stdlib.h>
#include <numeric>
#include <math.h>
#include <cassert>
#include <iostream>
#include <cmath>

void test_target_teams__distribute__parallel(){

    // Declare Size of Loop
    
    const int L = 10;

    // Initialize array
    int A = 0;

    // Computation
    
            
                #pragma omp target teams  map(tofrom: A) 
            {
            

            
                #pragma omp distribute 
                for (int i = 0 ; i < L ; i++ )
            
            {
        
            
                #pragma omp parallel 
            {
            

            
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
    test_target_teams__distribute__parallel();
}
