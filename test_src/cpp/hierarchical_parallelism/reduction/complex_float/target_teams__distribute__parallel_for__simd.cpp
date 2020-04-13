#include <iostream>
#include <limits>


#include <complex>
using namespace std;




bool almost_equal(complex<float> x, complex<float> y, int ulp) {

    bool r = std::fabs(x.real()-y.real()) <= std::numeric_limits<float>::epsilon() * std::fabs(x.real()+y.real()) * ulp ||  std::fabs(x.real()-y.real()) < std::numeric_limits<float>::min();
    bool i = std::fabs(x.imag()-y.imag()) <= std::numeric_limits<float>::epsilon() * std::fabs(x.imag()+y.imag()) * ulp ||  std::fabs(x.imag()-y.imag()) < std::numeric_limits<float>::min();
    return r && i;

}


#pragma omp declare reduction(ComplexReduction: complex<float>:   omp_out += omp_in) 


void test_target_teams__distribute__parallel_for__simd(){

 // Input and Outputs
 
 const int L = 5;
 const int M = 6;
 const int N = 7;

complex<float> counter{};

// Main program

#pragma omp target teams  reduction(  ComplexReduction  :counter)   map(tofrom:counter) 

{


#pragma omp distribute  

    for (int i = 0 ; i < L ; i++ )

{


#pragma omp parallel for  reduction(  ComplexReduction  :counter)  

    for (int j = 0 ; j < M ; j++ )

{


#pragma omp simd  reduction(  ComplexReduction  :counter)  

    for (int k = 0 ; k < N ; k++ )

{




counter += complex<float> { 1.0f };



}

}

}

}


// Validation
if ( !almost_equal(counter,complex<float> { L*M*N }, 10)  ) {
    std::cerr << "Expected: " << L*M*N << " Got: " << counter << std::endl;
    throw std::runtime_error( "target_teams__distribute__parallel_for__simd give incorect value when offloaded");
}

}
int main()
{
    test_target_teams__distribute__parallel_for__simd();
}
