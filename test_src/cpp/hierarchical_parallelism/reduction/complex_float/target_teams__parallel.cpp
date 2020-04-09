#include <iostream>
#include <stdexcept>

#include <omp.h>


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


void test_target_teams__parallel(){

 // Input and Outputs
 

complex<float> counter{};

// Main program

#pragma omp target teams  reduction(  ComplexReduction  :counter)   map(tofrom:counter) 

{

const int num_teams = omp_get_num_teams();


#pragma omp parallel  reduction(  ComplexReduction  :counter)  

{

const int num_threads = omp_get_num_threads();




counter += complex<float> { 1./(num_teams*num_threads) } ;



}

}


// Validation
if ( !almost_equal(counter,complex<float> { 1 }, 10)  ) {
    std::cerr << "Expected: " << 1 << " Get: " << counter << std::endl;
    throw std::runtime_error( "target_teams__parallel give incorect value when offloaded");
}

}
int main()
{
    test_target_teams__parallel();
}
