#include <iostream>
#include <cstdlib>
#include <algorithm>
bool almost_equal(float x, float gold, float rel_tol=1e-09, float abs_tol=0.0) {
  return std::abs(x-gold) <= std::max(rel_tol * std::max(std::abs(x), std::abs(gold)), abs_tol);
}
void test_target__parallel__for__simd() {
  const int N0 { 182 };
  const int N1 { 182 };
  const float expected_value { N0*N1 };
  float counter_N0{};
  #pragma omp target map(tofrom: counter_N0)
  #pragma omp parallel reduction(+: counter_N0)
  #pragma omp for
  for (int i0 = 0 ; i0 < N0 ; i0++ )
  {
    #pragma omp simd reduction(+: counter_N0)
    for (int i1 = 0 ; i1 < N1 ; i1++ )
    {
      counter_N0 = counter_N0 + 1. ;
    }
  }
  if (!almost_equal(counter_N0, expected_value, 0.01)) {
    std::cerr << "Expected: " << expected_value << " Got: " << counter_N0 << std::endl;
    std::exit(112);
  }
}
int main()
{
    test_target__parallel__for__simd();
}
