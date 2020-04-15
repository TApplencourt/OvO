#include <iostream>
#include <limits>
#include <cmath>




bool almost_equal(double x, double y, int ulp) {

     return std::fabs(x-y) <= std::numeric_limits<double>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<double>::min();

}



void test_target_parallel_for__simd.cpp(){

 // Input and Outputs
 
 const int L = 5;
 const int M = 6;

double counter{};

// Main program

#pragma omp target parallel for  reduction(  +  :counter)   map(tofrom:counter) 

    for (int i = 0 ; i < L ; i++ )

{


#pragma omp simd  reduction(  +  :counter)  

    for (int j = 0 ; j < M ; j++ )

{




counter += double { 1.0f };



}

}


// Validation
if ( !almost_equal(counter,double { L*M }, 10)  ) {
    std::cerr << "Expected: " << L*M << " Got: " << counter << std::endl;
    throw std::runtime_error( "target_parallel_for__simd.cpp give incorect value when offloaded");
}

}
int main()
{
    test_target_parallel_for__simd.cpp();
}
