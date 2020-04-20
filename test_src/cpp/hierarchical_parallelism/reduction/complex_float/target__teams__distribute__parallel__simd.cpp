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
bool almost_equal(complex<float> x, complex<float> gold, float tol) {
        return abs(gold) * (1-tol) <= abs(x) && abs(x) <= abs(gold) * (1 + tol ); 
}
#pragma omp declare reduction(+: complex<float>:   omp_out += omp_in) 
void test_target__teams__distribute__parallel__simd(){
 // Input and Outputs
 const int L = 5;
 const int M = 6;
complex<float> counter{};
// Main program
#pragma omp target   map(tofrom:counter) 
{
#pragma omp teams  reduction(+: counter)  
{
#pragma omp distribute  
    for (int i = 0 ; i < L ; i++ )
{
#pragma omp parallel  reduction(+: counter)  
{
const int num_threads = omp_get_num_threads();
#pragma omp simd  reduction(+: counter)  
    for (int j = 0 ; j < M ; j++ )
{
counter += complex<float> { 1.0f/num_threads };
}
}
}
}
}
// Validation
if ( !almost_equal(counter,complex<float> { L*M }, 0.1)  ) {
    std::cerr << "Expected: " << L*M << " Got: " << counter << std::endl;
    throw std::runtime_error( "target__teams__distribute__parallel__simd give incorect value when offloaded");
}
}
int main()
{
    test_target__teams__distribute__parallel__simd();
}
