#include <iostream>
#include <limits>
#include <cmath>
#include <stdexcept>
#



#ifdef _OPENMP
#include <omp.h>
#else
int omp_get_num_teams() {return 1;}
int omp_get_num_threads() {return 1;}
#endif


bool almost_equal(float x, float y, int ulp) {

     return std::fabs(x-y) <= std::numeric_limits<float>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<float>::min();

}

void test_target_teams__distribute__parallel(){

 // Input and Outputs
 
 const int L = 5;

float counter{};

// Main program

#pragma omp target teams  map(tofrom:counter) 

{


#pragma omp distribute 

    for (int i = 0 ; i < L ; i++ )

{


#pragma omp parallel 

{

const int num_threads = omp_get_num_threads();



#pragma omp atomic update

counter += float { 1.0f } / num_threads ;



}

}

}


// Validation
if ( !almost_equal(counter,float { L }, 10)  ) {
    std::cerr << "Expected: " << L << " Got: " << counter << std::endl;
    throw std::runtime_error( "target_teams__distribute__parallel give incorect value when offloaded");
}

}
int main()
{
    test_target_teams__distribute__parallel();
}
