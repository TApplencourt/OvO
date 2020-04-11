#include <iostream>
#include <stdexcept>

#include <omp.h>


#include <cmath>
#include <limits>



bool almost_equal(float x, float y, int ulp) {

     return std::fabs(x-y) <= std::numeric_limits<float>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<float>::min();

}



void test_target__teams__parallel(){

 // Input and Outputs
 

float counter{};

// Main program

#pragma omp target   map(tofrom:counter) 

{


#pragma omp teams  reduction(  +  :counter)  

{

const int num_teams = omp_get_num_teams();


#pragma omp parallel  reduction(  +  :counter)  

{

const int num_threads = omp_get_num_threads();




counter += float { 1.0f/(num_teams*num_threads) } ;



}

}

}


// Validation
if ( !almost_equal(counter,float { 1 }, 10)  ) {
    std::cerr << "Expected: " << 1 << " Get: " << counter << std::endl;
    throw std::runtime_error( "target__teams__parallel give incorect value when offloaded");
}

}
int main()
{
    test_target__teams__parallel();
}
