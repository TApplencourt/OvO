#include <iostream>
#include <cstdlib>
#include <cmath>
#ifdef _OPENMP
#include <omp.h>
#else
int omp_get_num_teams() {return 1;}
#endif
bool almost_equal(float x, float gold, float rel_tol=1e-09, float abs_tol=0.0) {
  return std::abs(x-gold) <= std::max(rel_tol * std::max(std::abs(x), std::abs(gold)), abs_tol);
}
void test_target__teams__parallel_for__simd() {
  const int N0 { 32 };
  const int N1 { 32 };
  const float expected_value { N0*N1 };
  float counter_teams{};
  #pragma omp target map(tofrom: counter_teams)
  #pragma omp teams num_teams(32) reduction(+: counter_teams)
  {
    #pragma omp parallel for reduction(+: counter_teams)
    for (int i0 = 0 ; i0 < N0 ; i0++ )
    {
      #pragma omp simd reduction(+: counter_teams)
      for (int i1 = 0 ; i1 < N1 ; i1++ )
      {
        counter_teams = counter_teams + float { float{ 1. } / omp_get_num_teams() };
      }
    }
  }
  if (!almost_equal(counter_teams, expected_value, 0.01)) {
    std::cerr << "Expected: " << expected_value << " Got: " << counter_teams << std::endl;
    std::exit(112);
  }
}
int main()
{
    test_target__teams__parallel_for__simd();
}
