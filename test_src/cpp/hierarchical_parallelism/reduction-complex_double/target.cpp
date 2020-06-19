#include <iostream>
#include <cstdlib>
#include <cmath>
#include <complex>
using std::complex;
bool almost_equal(complex<double> x, complex<double> gold, float tol) {
  return std::abs(gold) * (1-tol) <= std::abs(x) && std::abs(x) <= std::abs(gold) * (1 + tol);
}
void test_target() {
  const complex<double> expected_value { 1 };
  #pragma omp declare reduction(+: complex<double>: omp_out += omp_in)
  complex<double> counter_target{};
  #pragma omp target map(tofrom: counter_target)
  {
    counter_target = counter_target + complex<double> {  1. };
  }
  if (!almost_equal(counter_target, expected_value, 0.1)) {
    std::cerr << "Expected: " << expected_value << " Got: " << counter_target << std::endl;
    std::exit(112);
  }
}
int main()
{
    test_target();
}
