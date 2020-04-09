#include <iostream>
#include <stdexcept>


#include <cmath>
#include <limits>


#include <complex>
using namespace std;


bool almost_equal(complex<float> x, complex<float> y, int ulp) {

    bool r = std::fabs(x.real()-y.real()) <= std::numeric_limits<float>::epsilon() * std::fabs(x.real()+y.real()) * ulp ||  std::fabs(x.real()-y.real()) < std::numeric_limits<float>::min();
    bool i = std::fabs(x.imag()-y.imag()) <= std::numeric_limits<float>::epsilon() * std::fabs(x.imag()+y.imag()) * ulp ||  std::fabs(x.imag()-y.imag()) < std::numeric_limits<float>::min();
    return r && i;

}


#pragma omp declare reduction(ComplexReduction: complex<float>:   omp_out += omp_in) 


void test_target_parallel__for(){

 // Input and Outputs
 
 const int L = 5;

complex<float> counter{};

// Main program

#pragma omp target parallel  reduction(  ComplexReduction  :counter)   map(tofrom:counter) 

{


#pragma omp for  

    for (int i = 0 ; i < L ; i++ )

{




counter += complex<float> { 1 };



}

}


// Validation
if ( !almost_equal(counter,complex<float> { L }, 10)  ) {
    std::cerr << "Expected: " << L << " Get: " << counter << std::endl;
    throw std::runtime_error( "target_parallel__for give incorect value when offloaded");
}

}
int main()
{
    test_target_parallel__for();
}
