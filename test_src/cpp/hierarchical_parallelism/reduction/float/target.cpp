#include <iostream>
#include <limits>
#include <cmath>
#include <stdexcept>




bool almost_equal(float x, float y, int ulp) {

     return std::fabs(x-y) <= std::numeric_limits<float>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<float>::min();

}



void test_target(){

 // Input and Outputs
 

float counter{};

// Main program

#pragma omp target   map(tofrom:counter) 

{




counter += float { 1.0f };



}


// Validation
if ( !almost_equal(counter,float { 1 }, 10)  ) {
    std::cerr << "Expected: " << 1 << " Got: " << counter << std::endl;
    throw std::runtime_error( "target give incorect value when offloaded");
}

}
int main()
{
    test_target();
}
