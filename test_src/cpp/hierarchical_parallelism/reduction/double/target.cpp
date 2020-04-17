#include <iostream>
#include <cmath>
#include <stdexcept>




bool almost_equal(double x, double gold, float tol) {
    
        return gold * (1-tol) <= x && x <= gold * ( 1+tol );
    
}



void test_target(){

 // Input and Outputs
 

double counter{};

// Main program

#pragma omp target   map(tofrom:counter) 

{




counter += double { 1.0f };



}


// Validation
if ( !almost_equal(counter,double { 1 }, 0.1)  ) {
    std::cerr << "Expected: " << 1 << " Got: " << counter << std::endl;
    throw std::runtime_error( "target give incorect value when offloaded");
}

}
int main()
{
    test_target();
}
