#include <iostream>
#include <cstdlib>
#include <cmath>
#include <complex>
using std::complex;
#ifdef _OPENMP
#include <omp.h>
#else
int omp_get_num_teams() {return 1;}
#endif
bool almost_equal(complex<double> x, complex<double> gold, float tol) {
  if ( (std::signbit(std::real(x)) != std::signbit(std::real(gold))) or (std::signbit(std::imag(x)) != std::signbit(std::imag(gold))) )
  {
    x = std::abs(gold) - std::abs(x);
  }
  return std::abs(gold) * (1-tol) <= std::abs(x) && std::abs(x) <= std::abs(gold) * (1 + tol);
}
void test_target_teams__parallel_for__simd() {
  const int N0 { 182 };
  const int N1 { 182 };
  const complex<double> expected_value { N0*N1 };
  complex<double> counter_teams{};
  #pragma omp target teams map(tofrom: counter_teams)
  {
    #pragma omp parallel for
    for (int i0 = 0 ; i0 < N0 ; i0++ )
    {
      #pragma omp simd
      for (int i1 = 0 ; i1 < N1 ; i1++ )
      {
        counter_teams = counter_teams + complex<double> { double { 1. } / omp_get_num_teams() };
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
    test_target_teams__parallel_for__simd();
}
