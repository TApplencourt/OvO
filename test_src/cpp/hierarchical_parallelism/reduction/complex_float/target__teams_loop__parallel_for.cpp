#include <iostream>
#include <limits>
#include <cmath>

#include <complex>
using namespace std;




bool almost_equal(complex<float> x, complex<float> y, int ulp) {

    bool r = std::fabs(x.real()-y.real()) <= std::numeric_limits<float>::epsilon() * std::fabs(x.real()+y.real()) * ulp ||  std::fabs(x.real()-y.real()) < std::numeric_limits<float>::min();
    bool i = std::fabs(x.imag()-y.imag()) <= std::numeric_limits<float>::epsilon() * std::fabs(x.imag()+y.imag()) * ulp ||  std::fabs(x.imag()-y.imag()) < std::numeric_limits<float>::min();
    return r && i;

}


#pragma omp declare reduction(ComplexReduction: complex<float>:   omp_out += omp_in) 


void test_target__teams_loop__parallel_for.cpp(){

 // Input and Outputs
 
 const int L = 5;
 const int M = 6;

complex<float> counter{};

// Main program

#pragma omp target   map(tofrom:counter) 

{


#pragma omp teams loop  reduction(  ComplexReduction  :counter)  

    for (int i = 0 ; i < L ; i++ )

{


#pragma omp parallel for  reduction(  ComplexReduction  :counter)  

    for (int j = 0 ; j < M ; j++ )

{




counter += complex<float> { 1.0f };



}

}

}


// Validation
if ( !almost_equal(counter,complex<float> { L*M }, 10)  ) {
    std::cerr << "Expected: " << L*M << " Got: " << counter << std::endl;
    throw std::runtime_error( "target__teams_loop__parallel_for.cpp give incorect value when offloaded");
}

}
int main()
{
    test_target__teams_loop__parallel_for.cpp();
}
