#include <iostream>
#include <limits>
#include <cmath>
#include <stdexcept>




bool almost_equal(float x, float y, int ulp) {

     return std::fabs(x-y) <= std::numeric_limits<float>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<float>::min();

}



void test_target__teams_distribute__simd(){

 // Input and Outputs
 
 const int L = 5;
 const int M = 6;

float counter{};

// Main program

#pragma omp target   map(tofrom:counter) 

{


#pragma omp teams distribute  reduction(+: counter)  

    for (int i = 0 ; i < L ; i++ )

{


#pragma omp simd  reduction(+: counter)  

    for (int j = 0 ; j < M ; j++ )

{




counter += float { 1.0f };



}

}

}


// Validation
if ( !almost_equal(counter,float { L*M }, 10)  ) {
    std::cerr << "Expected: " << L*M << " Got: " << counter << std::endl;
    throw std::runtime_error( "target__teams_distribute__simd give incorect value when offloaded");
}

}
int main()
{
    test_target__teams_distribute__simd();
}
