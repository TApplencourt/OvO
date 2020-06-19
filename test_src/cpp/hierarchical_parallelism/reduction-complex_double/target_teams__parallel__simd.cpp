#include <iostream>
#include <cstdlib>
#include <cmath>
#include <complex>
using std::complex;
#ifdef _OPENMP
#include <omp.h>
#else
int omp_get_num_teams() {return 1;}
int omp_get_num_threads() {return 1;}
#endif
bool almost_equal(complex<double> x, complex<double> gold, float tol) {
  return std::abs(gold) * (1-tol) <= std::abs(x) && std::abs(x) <= std::abs(gold) * (1 + tol);
}
void test_target_teams__parallel__simd() {
  const int N0 { 262144 };
  const complex<double> expected_value { N0 };
  #pragma omp declare reduction(+: complex<double>: omp_out += omp_in)
  complex<double> counter_teams{};
  #pragma omp target teams map(tofrom: counter_teams) reduction(+: counter_teams)
  {
    #pragma omp parallel reduction(+: counter_teams)
    {
      #pragma omp simd reduction(+: counter_teams)
      for (int i0 = 0 ; i0 < N0 ; i0++ )
      {
        counter_teams = counter_teams + complex<double> { double { 1. } / ( omp_get_num_teams() * omp_get_num_threads() ) };
      }
    }
  }
  if (!almost_equal(counter_teams, expected_value, 0.1)) {
    std::cerr << "Expected: " << expected_value << " Got: " << counter_teams << std::endl;
    std::exit(112);
  }
}
int main()
{
    test_target_teams__parallel__simd();
}
