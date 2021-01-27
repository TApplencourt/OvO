#include <iostream>
#include <cstdlib>
#include <cmath>
#ifdef _OPENMP
#include <omp.h>
#else
int omp_get_num_teams() {return 1;}
#endif
bool almost_equal(float x, float gold, float tol) {
  return gold * (1-tol) <= x && x <= gold * (1 + tol);
}
void test_target_teams__parallel__for__simd() {
  const int N0 { 182 };
  const int N1 { 182 };
  const float expected_value { N0*N1 };
  float counter_teams{};
  #pragma omp target teams map(tofrom: counter_teams)
  {
    #pragma omp parallel
    #pragma omp for
    for (int i0 = 0 ; i0 < N0 ; i0++ )
    {
      #pragma omp simd
      for (int i1 = 0 ; i1 < N1 ; i1++ )
      {
        #pragma omp atomic update
        counter_teams = counter_teams + float { float{ 1. } / omp_get_num_teams() };
      }
    }
  }
  if (!almost_equal(counter_teams, expected_value, 0.1)) {
    std::cerr << "Expected: " << expected_value << " Got: " << counter_teams << std::endl;
    std::exit(112);
  }
}
int main()
{
    test_target_teams__parallel__for__simd();
}
