#include <iostream>
#include <cstdlib>
#include <algorithm>
#include <complex>
using std::complex;
#ifdef _OPENMP
#include <omp.h>
#else
int omp_get_num_teams() {return 1;}
void omp_set_num_teams(int _) { (void)_;}
#endif
bool almost_equal(complex<double> x, complex<double> gold, double rel_tol=1e-09, double abs_tol=0.0) {
  return std::abs(x-gold) <= std::max(rel_tol * std::max(std::abs(x), std::abs(gold)), abs_tol);
}
#pragma omp declare reduction(+: complex<double>: omp_out += omp_in)
void test_target_teams__parallel_for_simd() {
  const int N0 { 182 };
  const complex<double> expected_value { N0 };
  omp_set_num_teams(182);
  complex<double> counter_teams{};
  #pragma omp target teams reduction(+: counter_teams)
  {
    #pragma omp parallel for simd reduction(+: counter_teams)
    for (int i0 = 0 ; i0 < N0 ; i0++ )
    {
      counter_teams = counter_teams + complex<double> { double { 1. } / omp_get_num_teams() };
    }
  }
  if (!almost_equal(counter_teams, expected_value, 0.01)) {
    std::cerr << "Expected: " << expected_value << " Got: " << counter_teams << std::endl;
    std::exit(112);
  }
}
int main()
{
    test_target_teams__parallel_for_simd();
}
