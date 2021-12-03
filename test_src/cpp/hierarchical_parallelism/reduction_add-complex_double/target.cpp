#include <iostream>
#include <cstdlib>
#include <algorithm>
#include <complex>
using std::complex;
bool almost_equal(complex<double> x, complex<double> gold, double rel_tol=1e-09, double abs_tol=0.0) {
  return std::abs(x-gold) <= std::max(rel_tol * std::max(std::abs(x), std::abs(gold)), abs_tol);
}
#pragma omp declare reduction(+: complex<double>: omp_out += omp_in)
void test_target() {
  const complex<double> expected_value { 1 };
  complex<double> counter_target{};
  #pragma omp target map(tofrom: counter_target)
  {
    counter_target = counter_target + complex<double> { 1. };
  }
  if (!almost_equal(counter_target, expected_value, 0.01)) {
    std::cerr << "Expected: " << expected_value << " Got: " << counter_target << std::endl;
    std::exit(112);
  }
}
int main()
{
    test_target();
}
