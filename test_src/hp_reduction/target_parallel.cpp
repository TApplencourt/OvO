#include <iostream>
#include <stdexcept>
#include <omp.h>

#include <cmath>
#include <limits>
template<class T>
bool almost_equal(T x, T y, int ulp) {
    return std::fabs(x-y) <= std::numeric_limits<T>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<T>::min();
}

template<class T>
void test_target_parallel(){

 // Input and Outputs
 

T counter{};

// Main program

#pragma omp target parallel  reduction(+:counter)   map(tofrom:counter) 

{


const int num_threads = omp_get_num_threads();




counter = counter + 1./num_threads;



}


// Validation
if ( !almost_equal(counter,T{ 1 }, 1)  ) {
    std::cerr << "Expected: " << 1 << " Get: " << counter << std::endl;
    throw std::runtime_error( "target_parallel give incorect value when offloaded");
}

}
int main()
{
    test_target_parallel<double>();
}
