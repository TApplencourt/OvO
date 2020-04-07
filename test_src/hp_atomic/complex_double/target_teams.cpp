#include <iostream>
#include <stdexcept>

#include <omp.h>



#include <complex>


#include <cmath>
#include <limits>


#include <complex>
using namespace std;


bool almost_equal(complex<double> x, complex<double> y, int ulp) {

    bool r = std::fabs(x.real()-y.real()) <= std::numeric_limits<double>::epsilon() * std::fabs(x.real()+y.real()) * ulp ||  std::fabs(x.real()-y.real()) < std::numeric_limits<double>::min();
    bool i = std::fabs(x.imag()-y.imag()) <= std::numeric_limits<double>::epsilon() * std::fabs(x.imag()+y.imag()) * ulp ||  std::fabs(x.imag()-y.imag()) < std::numeric_limits<double>::min();
    return r && i;

}

void test_target_teams(){

 // Input and Outputs
 

complex<double> counter{};

// Main program

#pragma omp target teams  map(tofrom:counter) 

{

const int num_teams = omp_get_num_teams();



#pragma omp atomic update

counter += complex<double> { 1./num_teams } ;



}


// Validation
if ( !almost_equal(counter,complex<double> { 1 }, 1)  ) {
    std::cerr << "Expected: " << 1 << " Get: " << counter << std::endl;
    throw std::runtime_error( "target_teams give incorect value when offloaded");
}

}
int main()
{
    test_target_teams();
}
