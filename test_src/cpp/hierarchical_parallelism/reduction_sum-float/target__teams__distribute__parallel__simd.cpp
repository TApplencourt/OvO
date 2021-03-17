#include <iostream>
#include <cstdlib>
#include <cmath>
#ifdef _OPENMP
#include <omp.h>
#else
int omp_get_num_threads() {return 1;}
#endif
bool almost_equal(float x, float gold, float tol) {
  if ( std::signbit(x) != std::signbit(gold) )
  {
    x = std::abs(gold) - std::abs(x);
  }
  return std::abs(gold) * (1-tol) <= std::abs(x) && std::abs(x) <= std::abs(gold) * (1 + tol);
}
void test_target__teams__distribute__parallel__simd() {
  const int N0 { 182 };
  const int N1 { 182 };
  const float expected_value { N0*N1 };
  float counter_N0{};
  #pragma omp target
  #pragma omp teams reduction(+: counter_N0)
  #pragma omp distribute
  for (int i0 = 0 ; i0 < N0 ; i0++ )
  {
    #pragma omp parallel reduction(+: counter_N0)
    {
      #pragma omp simd reduction(+: counter_N0)
      for (int i1 = 0 ; i1 < N1 ; i1++ )
      {
        counter_N0 = counter_N0 + float { float{ 1. } / omp_get_num_threads() };
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
