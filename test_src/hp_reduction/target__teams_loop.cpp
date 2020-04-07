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
void test_target__teams_loop(){

 // Input and Outputs
 
 const int L = 5;

T counter{};

// Main program

#pragma omp target   defaultmap(tofrom:scalar) 

{


#pragma omp teams loop  reduction(+:counter)  

    for (int i = 0 ; i < L ; i++ )

{




counter = counter + 1;



}

}


// Validation
if ( !almost_equal(counter,T{ L }, 1)  ) {
    std::cerr << "Expected: " << L << " Get: " << counter << std::endl;
    throw std::runtime_error( "target__teams_loop give incorect value when offloaded");
}

}
int main()
{
    test_target__teams_loop<double>();
}
