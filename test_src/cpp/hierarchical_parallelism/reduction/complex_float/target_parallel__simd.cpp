#include <iostream>
#include <limits>
#include <cmath>

#include <complex>
using namespace std;



#ifdef _OPENMP
#include <omp.h>
#else
int omp_get_num_teams() {return 1;}
int omp_get_num_threads() {return 1;}
#endif


bool almost_equal(complex<float> x, complex<float> y, int ulp) {

    bool r = std::fabs(x.real()-y.real()) <= std::numeric_limits<float>::epsilon() * std::fabs(x.real()+y.real()) * ulp ||  std::fabs(x.real()-y.real()) < std::numeric_limits<float>::min();
    bool i = std::fabs(x.imag()-y.imag()) <= std::numeric_limits<float>::epsilon() * std::fabs(x.imag()+y.imag()) * ulp ||  std::fabs(x.imag()-y.imag()) < std::numeric_limits<float>::min();
    return r && i;

}


#pragma omp declare reduction(ComplexReduction: complex<float>:   omp_out += omp_in) 


void test_target_parallel__simd(){

 // Input and Outputs
 
 const int L = 5;

complex<float> counter{};

// Main program

#pragma omp target parallel  reduction(  ComplexReduction  :counter)   map(tofrom:counter) 

{

const int num_threads = omp_get_num_threads();


#pragma omp simd  reduction(  ComplexReduction  :counter)  

    for (int i = 0 ; i < L ; i++ )

{




counter += complex<float> { 1.0f/num_threads };



}

}


// Validation
if ( !almost_equal(counter,complex<float> { L }, 10)  ) {
    std::cerr << "Expected: " << L << " Got: " << counter << std::endl;
    throw std::runtime_error( "target_parallel__simd give incorect value when offloaded");
}

}
int main()
{
    test_target_parallel__simd();
}
