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
void test_target__teams_distribute__parallel__simd() {
  const int N0 { 32 };
  const int N1 { 32 };
  const float expected_value { N0*N1 };
  float counter_N0{};
  #pragma omp target map(tofrom: counter_N0)
  #pragma omp teams distribute
  for (int i0 = 0 ; i0 < N0 ; i0++ )
  {
    #pragma omp parallel num_threads(32)
    {
      #pragma omp simd
      for (int i1 = 0 ; i1 < N1 ; i1++ )
      {
        #pragma omp atomic update
        counter_N0 = counter_N0 + float { float{ 1. } / omp_get_num_threads() };
      }
    }
  }
  if (!almost_equal(counter_N0, expected_value, 0.01)) {
    std::cerr << "Expected: " << expected_value << " Got: " << counter_N0 << std::endl;
    std::exit(112);
  }
}
int main()
{
    test_target__teams_distribute__parallel__simd();
}
