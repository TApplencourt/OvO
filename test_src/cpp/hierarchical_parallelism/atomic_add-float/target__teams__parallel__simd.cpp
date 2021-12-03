#include <iostream>
#include <cstdlib>
#include <algorithm>
#ifdef _OPENMP
#include <omp.h>
#else
int omp_get_num_teams() {return 1;}
void omp_set_num_teams(int _) {}
int omp_get_num_threads() {return 1;}
#endif
bool almost_equal(float x, float gold, float rel_tol=1e-09, float abs_tol=0.0) {
  return std::abs(x-gold) <= std::max(rel_tol * std::max(std::abs(x), std::abs(gold)), abs_tol);
}
void test_target__teams__parallel__simd() {
  const int N0 { 32 };
  const float expected_value { N0 };
  omp_set_num_teams(32);
  float counter_teams{};
  #pragma omp target map(tofrom: counter_teams)
  #pragma omp teams
  {
    #pragma omp parallel num_threads(32)
    {
      #pragma omp simd
      for (int i0 = 0 ; i0 < N0 ; i0++ )
      {
        #pragma omp atomic update
        counter_teams = counter_teams + float { float{ 1. } / ( omp_get_num_teams() * omp_get_num_threads() ) };
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
    test_target__teams__parallel__simd();
}
