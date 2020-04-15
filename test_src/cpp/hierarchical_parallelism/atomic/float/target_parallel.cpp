#include <iostream>
#include <limits>
#include <cmath>




#ifdef _OPENMP
#include <omp.h>
#else
int omp_get_num_teams() {return 1;}
int omp_get_num_threads() {return 1;}
#endif


bool almost_equal(float x, float y, int ulp) {

     return std::fabs(x-y) <= std::numeric_limits<float>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<float>::min();

}

void test_target_parallel.cpp(){

 // Input and Outputs
 

float counter{};

// Main program

#pragma omp target parallel  map(tofrom:counter) 

{

const int num_threads = omp_get_num_threads();



#pragma omp atomic update

counter += float { 1.0f } / num_threads ;



}


// Validation
if ( !almost_equal(counter,float { 1 }, 10)  ) {
    std::cerr << "Expected: " << 1 << " Got: " << counter << std::endl;
    throw std::runtime_error( "target_parallel.cpp give incorect value when offloaded");
}

}
int main()
{
    test_target_parallel.cpp();
}
