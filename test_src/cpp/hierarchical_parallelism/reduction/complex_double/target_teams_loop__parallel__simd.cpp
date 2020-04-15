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


bool almost_equal(complex<double> x, complex<double> y, int ulp) {

    bool r = std::fabs(x.real()-y.real()) <= std::numeric_limits<double>::epsilon() * std::fabs(x.real()+y.real()) * ulp ||  std::fabs(x.real()-y.real()) < std::numeric_limits<double>::min();
    bool i = std::fabs(x.imag()-y.imag()) <= std::numeric_limits<double>::epsilon() * std::fabs(x.imag()+y.imag()) * ulp ||  std::fabs(x.imag()-y.imag()) < std::numeric_limits<double>::min();
    return r && i;

}


#pragma omp declare reduction(ComplexReduction: complex<double>:   omp_out += omp_in) 


void test_target_teams_loop__parallel__simd.cpp(){

 // Input and Outputs
 
 const int L = 5;
 const int M = 6;

complex<double> counter{};

// Main program

#pragma omp target teams loop  reduction(  ComplexReduction  :counter)   map(tofrom:counter) 

    for (int i = 0 ; i < L ; i++ )

{


#pragma omp parallel  reduction(  ComplexReduction  :counter)  

{

const int num_threads = omp_get_num_threads();


#pragma omp simd  reduction(  ComplexReduction  :counter)  

    for (int j = 0 ; j < M ; j++ )

{




counter += complex<double> { 1.0f/num_threads };



}

}

}


// Validation
if ( !almost_equal(counter,complex<double> { L*M }, 10)  ) {
    std::cerr << "Expected: " << L*M << " Got: " << counter << std::endl;
    throw std::runtime_error( "target_teams_loop__parallel__simd.cpp give incorect value when offloaded");
}

}
int main()
{
    test_target_teams_loop__parallel__simd.cpp();
}
