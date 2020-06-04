#include <iostream>
#include <cstdlib>
#include <cmath>
#include <complex>
using namespace std;
#ifdef _OPENMP
#include <omp.h>
#else
int omp_get_num_teams()   {return 1;}
int omp_get_num_threads() {return 1;}
#endif
bool almost_equal(complex<double> x, complex<double> gold, float tol) {
        return abs(gold) * (1-tol) <= abs(x) && abs(x) <= abs(gold) * (1 + tol);
}
#pragma omp declare reduction(+: complex<double>: omp_out += omp_in)
void test_target_teams_distribute__parallel__simd(){
 const int N_i = 64;
 const int N_j = 64;
 complex<double> counter{};
#pragma omp target teams distribute reduction(+: counter) map(tofrom: counter) 
    for (int i = 0 ; i < N_i ; i++ )
    {
#pragma omp parallel reduction(+: counter)
    {
const int num_threads = omp_get_num_threads();
#pragma omp simd reduction(+: counter)
    for (int j = 0 ; j < N_j ; j++ )
    {
counter += complex<double> { 1.0f/num_threads };
    }
    }
    }
if ( !almost_equal(counter,complex<double> { N_i*N_j }, 0.1)  ) {
    std::cerr << "Expected: " << N_i*N_j << " Got: " << counter << std::endl;
    std::exit(112);
}
}
int main()
{
    test_target_teams_distribute__parallel__simd();
}
