#include <iostream>
#include <cmath>
#include <stdexcept>
#include <complex>
using namespace std;
bool almost_equal(complex<float> x, complex<float> gold, float tol) {
        return abs(gold) * (1-tol) <= abs(x) && abs(x) <= abs(gold) * (1 + tol ); 
}
#pragma omp declare reduction(+: complex<float>:   omp_out += omp_in) 
void test_target_teams_loop__parallel__loop__simd(){
 // Input and Outputs
 const int L = 5;
 const int M = 6;
 const int N = 7;
complex<float> counter{};
// Main program
#pragma omp target teams loop  reduction(+: counter)   map(tofrom:counter) 
    for (int i = 0 ; i < L ; i++ )
{
#pragma omp parallel  reduction(+: counter)  
{
#pragma omp loop  
    for (int j = 0 ; j < M ; j++ )
{
#pragma omp simd  reduction(+: counter)  
    for (int k = 0 ; k < N ; k++ )
{
counter += complex<float> { 1.0f };
}
}
}
}
// Validation
if ( !almost_equal(counter,complex<float> { L*M*N }, 0.1)  ) {
    std::cerr << "Expected: " << L*M*N << " Got: " << counter << std::endl;
    throw std::runtime_error( "target_teams_loop__parallel__loop__simd give incorect value when offloaded");
}
}
int main()
{
    test_target_teams_loop__parallel__loop__simd();
}
