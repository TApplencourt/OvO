#include <iostream>
#include <stdexcept>

#include <omp.h>




#include <cmath>
#include <limits>



bool almost_equal(float x, float y, int ulp) {

     return std::fabs(x-y) <= std::numeric_limits<float>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<float>::min();

}

void test_target_teams(){

 // Input and Outputs
 

float counter{};

// Main program

#pragma omp target teams  map(tofrom:counter) 

{

const int num_teams = omp_get_num_teams();



#pragma omp atomic update

counter += float { 1.0f } / num_teams  ;



}


// Validation
if ( !almost_equal(counter,float { 1 }, 10)  ) {
    std::cerr << "Expected: " << 1 << " Get: " << counter << std::endl;
    throw std::runtime_error( "target_teams give incorect value when offloaded");
}

}
int main()
{
    test_target_teams();
}
