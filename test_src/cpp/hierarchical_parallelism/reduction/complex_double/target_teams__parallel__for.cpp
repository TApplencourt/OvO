#include <iostream>
#include <limits>
#include <cmath>
#include <stdexcept>

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


#pragma omp declare reduction(+: complex<double>:   omp_out += omp_in) 


void test_target_teams__parallel__for(){

 // Input and Outputs
 
 const int L = 5;

complex<double> counter{};

// Main program

#pragma omp target teams  reduction(+: counter)   map(tofrom:counter) 

{

const int num_teams = omp_get_num_teams();


#pragma omp parallel  reduction(+: counter)  

{


#pragma omp for  

    for (int i = 0 ; i < L ; i++ )

{




counter += complex<double> { 1.0f/num_teams } ;



}

}

}


// Validation
if ( !almost_equal(counter,complex<double> { L }, 10)  ) {
    std::cerr << "Expected: " << L << " Got: " << counter << std::endl;
    throw std::runtime_error( "target_teams__parallel__for give incorect value when offloaded");
}

}
int main()
{
    test_target_teams__parallel__for();
}
