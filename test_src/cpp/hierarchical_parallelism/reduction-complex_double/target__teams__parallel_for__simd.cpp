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
void test_target__teams__parallel_for__simd(){
 const int N0 = 512;
 const int N1 = 512;
 complex<double> counter{};
#pragma omp target map(tofrom: counter)
#pragma omp teams reduction(+: counter)
    {
const int num_teams = omp_get_num_teams();
#pragma omp parallel for reduction(+: counter)
      for (int i0 = 0 ; i0 < N0 ; i0++ )
      {
#pragma omp simd reduction(+: counter)
      for (int i1 = 0 ; i1 < N1 ; i1++ )
      {
counter += complex<double> { 1.0f/num_teams } ;
    }
    }
    }
if ( !almost_equal(counter,complex<double> { N0*N1 }, 0.1)  ) {
    std::cerr << "Expected: " << N0*N1 << " Got: " << counter << std::endl;
    std::exit(112);
}
}
int main()
{
    test_target__teams__parallel_for__simd();
}
