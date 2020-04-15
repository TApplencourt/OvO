#include <iostream>
#include <limits>
#include <cmath>





bool almost_equal(double x, double y, int ulp) {

     return std::fabs(x-y) <= std::numeric_limits<double>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<double>::min();

}

void test_target.cpp(){

 // Input and Outputs
 

double counter{};

// Main program

#pragma omp target  map(tofrom:counter) 

{



#pragma omp atomic update

counter += double { 1 };



}


// Validation
if ( !almost_equal(counter,double { 1 }, 10)  ) {
    std::cerr << "Expected: " << 1 << " Got: " << counter << std::endl;
    throw std::runtime_error( "target.cpp give incorect value when offloaded");
}

}
int main()
{
    test_target.cpp();
}
