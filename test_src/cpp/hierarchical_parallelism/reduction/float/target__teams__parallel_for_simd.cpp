#include <iostream>
#include <cmath>
#include <stdexcept>
#ifdef _OPENMP
#include <omp.h>
#else
int omp_get_num_teams() {return 1;}
int omp_get_num_threads() {return 1;}
#endif
bool almost_equal(float x, float gold, float tol) {
        return gold * (1-tol) <= x && x <= gold * ( 1+tol );
}
void test_target__teams__parallel_for_simd(){
 // Input and Outputs
 const int L = 5;
float counter{};
// Main program
#pragma omp target   map(tofrom:counter) 
{
#pragma omp teams  reduction(+: counter)  
{
const int num_teams = omp_get_num_teams();
#pragma omp parallel for simd  reduction(+: counter)  
    for (int i = 0 ; i < L ; i++ )
{
counter += float { 1.0f/num_teams } ;
}
}
}
// Validation
if ( !almost_equal(counter,float { L }, 0.1)  ) {
    std::cerr << "Expected: " << L << " Got: " << counter << std::endl;
    throw std::runtime_error( "target__teams__parallel_for_simd give incorect value when offloaded");
}
}
int main()
{
    test_target__teams__parallel_for_simd();
}
