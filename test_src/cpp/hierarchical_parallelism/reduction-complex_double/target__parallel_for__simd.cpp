#include <iostream>
#include <cstdlib>
#include <cmath>
#include <complex>
using std::complex;
bool almost_equal(complex<double> x, complex<double> gold, float tol) {
  return std::abs(gold) * (1-tol) <= std::abs(x) && std::abs(x) <= std::abs(gold) * (1 + tol);
}
#pragma omp declare reduction(+: complex<double>: omp_out += omp_in)
void test_target__parallel_for__simd() {
  const int N0 { 182 };
  const int N1 { 182 };
  const complex<double> expected_value { N0*N1 };
  complex<double> counter_N0{};
  #pragma omp target map(tofrom: counter_N0)
  #pragma omp parallel for reduction(+: counter_N0)
  for (int i0 = 0 ; i0 < N0 ; i0++ )
  {
    #pragma omp simd reduction(+: counter_N0)
    for (int i1 = 0 ; i1 < N1 ; i1++ )
    {
      counter_N0 = counter_N0 + complex<double> {  1. };
    }
  }
  if (!almost_equal(counter_N0, expected_value, 0.1)) {
    std::cerr << "Expected: " << expected_value << " Got: " << counter_N0 << std::endl;
    std::exit(112);
  }
}
int main()
{
    test_target__parallel_for__simd();
}
