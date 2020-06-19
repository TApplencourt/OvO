#include <iostream>
#include <cstdlib>
#include <cmath>
#include <complex>
using std::complex;
bool almost_equal(complex<double> x, complex<double> gold, float tol) {
  return std::abs(gold) * (1-tol) <= std::abs(x) && std::abs(x) <= std::abs(gold) * (1 + tol);
}
void test_target_simd() {
  const int N0 { 262144 };
  const complex<double> expected_value { N0 };
  #pragma omp declare reduction(+: complex<double>: omp_out += omp_in)
  complex<double> counter_N0{};
  #pragma omp target simd map(tofrom: counter_N0) reduction(+: counter_N0)
  for (int i0 = 0 ; i0 < N0 ; i0++ )
  {
    counter_N0 = counter_N0 +  1. ;
  }
  if (!almost_equal(counter_N0, expected_value, 0.1)) {
    std::cerr << "Expected: " << expected_value << " Got: " << counter_N0 << std::endl;
    std::exit(112);
  }
}
int main()
{
    test_target_simd();
}
