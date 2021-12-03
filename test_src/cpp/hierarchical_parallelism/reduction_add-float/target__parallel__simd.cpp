#include <iostream>
#include <cstdlib>
#include <algorithm>
#ifdef _OPENMP
#include <omp.h>
#else
int omp_get_num_threads() {return 1;}
#endif
bool almost_equal(float x, float gold, float rel_tol=1e-09, float abs_tol=0.0) {
  return std::abs(x-gold) <= std::max(rel_tol * std::max(std::abs(x), std::abs(gold)), abs_tol);
}
void test_target__parallel__simd() {
  const int N0 { 182 };
  const float expected_value { N0 };
  float counter_parallel{};
  #pragma omp target map(tofrom: counter_parallel)
  #pragma omp parallel num_threads(182) reduction(+: counter_parallel)
  {
    #pragma omp simd reduction(+: counter_parallel)
    for (int i0 = 0 ; i0 < N0 ; i0++ )
    {
      counter_parallel = counter_parallel + float { float{ 1. } / omp_get_num_threads() };
    }
  }
  if (!almost_equal(counter_parallel, expected_value, 0.01)) {
    std::cerr << "Expected: " << expected_value << " Got: " << counter_parallel << std::endl;
    std::exit(112);
  }
}
int main()
{
    test_target__parallel__simd();
}
