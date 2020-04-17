#include <iostream>
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


bool almost_equal(complex<double> x, complex<double> gold, float tol) {
    
        return abs(gold) * (1-tol) <= abs(x) && abs(x) <= abs(gold) * (1 + tol ); 
    
}


#pragma omp declare reduction(+: complex<double>:   omp_out += omp_in) 


void test_target_teams__parallel__simd(){

 // Input and Outputs
 
 const int L = 5;

complex<double> counter{};

// Main program

#pragma omp target teams  reduction(+: counter)   map(tofrom:counter) 

{

const int num_teams = omp_get_num_teams();


#pragma omp parallel  reduction(+: counter)  

{

const int num_threads = omp_get_num_threads();


#pragma omp simd  reduction(+: counter)  

    for (int i = 0 ; i < L ; i++ )

{




counter += complex<double> { 1.0f/(num_teams*num_threads) } ;



}

}

}


// Validation
if ( !almost_equal(counter,complex<double> { L }, 0.1)  ) {
    std::cerr << "Expected: " << L << " Got: " << counter << std::endl;
    throw std::runtime_error( "target_teams__parallel__simd give incorect value when offloaded");
}

}
int main()
{
    test_target_teams__parallel__simd();
}
