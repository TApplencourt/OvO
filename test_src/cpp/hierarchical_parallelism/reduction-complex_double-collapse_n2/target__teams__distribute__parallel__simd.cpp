#include <iostream>
#include <cstdlib>
#include <cmath>
#include <complex>
using std::complex;
#ifdef _OPENMP
#include <omp.h>
#else
int omp_get_num_threads() {return 1;}
#endif
bool almost_equal(complex<double> x, complex<double> gold, float tol) {
  return std::abs(gold) * (1-tol) <= std::abs(x) && std::abs(x) <= std::abs(gold) * (1 + tol);
}
void test_target__teams__distribute__parallel__simd() {
  const int N0 { 23 };
  const int N1 { 23 };
  const int N2 { 23 };
  const int N3 { 23 };
  const complex<double> expected_value { N0*N1*N2*N3 };
  #pragma omp declare reduction(+: complex<double>: omp_out += omp_in)
  complex<double> counter_N0{};
  #pragma omp target map(tofrom: counter_N0)
  #pragma omp teams reduction(+: counter_N0)
  #pragma omp distribute collapse(2)
  for (int i0 = 0 ; i0 < N0 ; i0++ )
  for (int i1 = 0 ; i1 < N1 ; i1++ )
  {
    #pragma omp parallel reduction(+: counter_N0)
    {
      #pragma omp simd reduction(+: counter_N0) collapse(2)
      for (int i2 = 0 ; i2 < N2 ; i2++ )
      for (int i3 = 0 ; i3 < N3 ; i3++ )
      {
        counter_N0 = counter_N0 + complex<double> { double { 1. } / omp_get_num_threads() };
      }
    }
  }
  if (!almost_equal(counter_N0, expected_value, 0.1)) {
    std::cerr << "Expected: " << expected_value << " Got: " << counter_N0 << std::endl;
    std::exit(112);
  }
}
int main()
{
    test_target__teams__distribute__parallel__simd();
}
