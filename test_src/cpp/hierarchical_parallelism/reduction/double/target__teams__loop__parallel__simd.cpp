#include <iostream>
#include <cmath>
#include <stdexcept>
#ifdef _OPENMP
#include <omp.h>
#else
int omp_get_num_teams() {return 1;}
int omp_get_num_threads() {return 1;}
#endif
bool almost_equal(double x, double gold, float tol) {
        return gold * (1-tol) <= x && x <= gold * ( 1+tol );
}
void test_target__teams__loop__parallel__simd(){
 // Input and Outputs
 const int L = 5;
 const int M = 6;
double counter{};
// Main program
#pragma omp target   map(tofrom:counter) 
{
#pragma omp teams  reduction(+: counter)  
{
#pragma omp loop  reduction(+: counter)  
    for (int i = 0 ; i < L ; i++ )
{
#pragma omp parallel  reduction(+: counter)  
{
const int num_threads = omp_get_num_threads();
#pragma omp simd  reduction(+: counter)  
    for (int j = 0 ; j < M ; j++ )
{
counter += double { 1.0f/num_threads };
}
}
}
}
}
// Validation
if ( !almost_equal(counter,double { L*M }, 0.1)  ) {
    std::cerr << "Expected: " << L*M << " Got: " << counter << std::endl;
    throw std::runtime_error( "target__teams__loop__parallel__simd give incorect value when offloaded");
}
}
int main()
{
    test_target__teams__loop__parallel__simd();
}
