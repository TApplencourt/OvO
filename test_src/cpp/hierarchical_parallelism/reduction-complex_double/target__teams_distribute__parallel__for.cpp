#include <iostream>
#include <cstdlib>
#include <cmath>
#include <complex>
using std::complex;
bool almost_equal(complex<double> x, complex<double> gold, float tol) {
  return std::abs(gold) * (1-tol) <= std::abs(x) && std::abs(x) <= std::abs(gold) * (1 + tol);
}
void test_target__teams_distribute__parallel__for() {
  const int N0 { 512 };
  const int N1 { 512 };
  const complex<double> expected_value { N0*N1 };
  #pragma omp declare reduction(+: complex<double>: omp_out += omp_in)
  complex<double> counter_N0{};
  #pragma omp target map(tofrom: counter_N0)
  #pragma omp teams distribute reduction(+: counter_N0)
  for (int i0 = 0 ; i0 < N0 ; i0++ )
  {
    #pragma omp parallel reduction(+: counter_N0)
    #pragma omp for
    for (int i1 = 0 ; i1 < N1 ; i1++ )
    {
      counter_N0 = counter_N0 +  1. ;
    }
  }
  if (!almost_equal(counter_N0, expected_value, 0.1)) {
    std::cerr << "Expected: " << expected_value << " Got: " << counter_N0 << std::endl;
    std::exit(112);
  }
}
int main()
{
    test_target__teams_distribute__parallel__for();
}
