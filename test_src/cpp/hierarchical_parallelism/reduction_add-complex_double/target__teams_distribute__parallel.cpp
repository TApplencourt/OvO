#include <iostream>
#include <cstdlib>
#include <algorithm>
#include <complex>
using std::complex;
#ifdef _OPENMP
#include <omp.h>
#else
int omp_get_num_threads() {return 1;}
#endif
bool almost_equal(complex<double> x, complex<double> gold, double rel_tol=1e-09, double abs_tol=0.0) {
  return std::abs(x-gold) <= std::max(rel_tol * std::max(std::abs(x), std::abs(gold)), abs_tol);
}
#pragma omp declare reduction(+: complex<double>: omp_out += omp_in)
void test_target__teams_distribute__parallel() {
  const int N0 { 182 };
  const complex<double> expected_value { N0 };
  complex<double> counter_N0{};
  #pragma omp target map(tofrom: counter_N0)
  #pragma omp teams distribute reduction(+: counter_N0)
  for (int i0 = 0 ; i0 < N0 ; i0++ )
  {
    #pragma omp parallel num_threads(182) reduction(+: counter_N0)
    {
      counter_N0 = counter_N0 + complex<double> { double { 1. } / omp_get_num_threads() };
    }
  }
  if (!almost_equal(counter_N0, expected_value, 0.01)) {
    std::cerr << "Expected: " << expected_value << " Got: " << counter_N0 << std::endl;
    std::exit(112);
  }
}
int main()
{
    test_target__teams_distribute__parallel();
}
