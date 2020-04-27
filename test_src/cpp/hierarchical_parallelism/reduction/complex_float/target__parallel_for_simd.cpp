#include <iostream>
#include <cmath>
#include <stdexcept>
#include <complex>
using namespace std;
bool almost_equal(complex<float> x, complex<float> gold, float tol) {
        return abs(gold) * (1-tol) <= abs(x) && abs(x) <= abs(gold) * (1 + tol ); 
}
#pragma omp declare reduction(+: complex<float>:   omp_out += omp_in) 
void test_target__parallel_for_simd(){
 // Input and Outputs
 const int L = 262144;
complex<float> counter{};
// Main program
#pragma omp target   map(tofrom:counter) 
{
#pragma omp parallel for simd  reduction(+: counter)  
    for (int i = 0 ; i < L ; i++ )
{
counter += complex<float> { 1.0f };
    }
    }
// Validation
if ( !almost_equal(counter,complex<float> { L }, 0.1)  ) {
    std::cerr << "Expected: " << L << " Got: " << counter << std::endl;
    throw std::runtime_error( "target__parallel_for_simd give incorect value when offloaded");
}
}
int main()
{
    test_target__parallel_for_simd();
}
