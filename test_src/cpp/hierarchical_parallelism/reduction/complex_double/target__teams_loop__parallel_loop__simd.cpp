#include <iostream>
#include <limits>


#include <complex>
using namespace std;




bool almost_equal(complex<double> x, complex<double> y, int ulp) {

    bool r = std::fabs(x.real()-y.real()) <= std::numeric_limits<double>::epsilon() * std::fabs(x.real()+y.real()) * ulp ||  std::fabs(x.real()-y.real()) < std::numeric_limits<double>::min();
    bool i = std::fabs(x.imag()-y.imag()) <= std::numeric_limits<double>::epsilon() * std::fabs(x.imag()+y.imag()) * ulp ||  std::fabs(x.imag()-y.imag()) < std::numeric_limits<double>::min();
    return r && i;

}


#pragma omp declare reduction(ComplexReduction: complex<double>:   omp_out += omp_in) 


void test_target__teams_loop__parallel_loop__simd(){

 // Input and Outputs
 
 const int L = 5;
 const int M = 6;
 const int N = 7;

complex<double> counter{};

// Main program

#pragma omp target   map(tofrom:counter) 

{


#pragma omp teams loop  reduction(  ComplexReduction  :counter)  

    for (int i = 0 ; i < L ; i++ )

{


#pragma omp parallel loop  reduction(  ComplexReduction  :counter)  

    for (int j = 0 ; j < M ; j++ )

{


#pragma omp simd  reduction(  ComplexReduction  :counter)  

    for (int k = 0 ; k < N ; k++ )

{




counter += complex<double> { 1.0f };



}

}

}

}


// Validation
if ( !almost_equal(counter,complex<double> { L*M*N }, 10)  ) {
    std::cerr << "Expected: " << L*M*N << " Got: " << counter << std::endl;
    throw std::runtime_error( "target__teams_loop__parallel_loop__simd give incorect value when offloaded");
}

}
int main()
{
    test_target__teams_loop__parallel_loop__simd();
}
