#include <iostream>
#include <cstdlib>
#include <cmath>
#ifdef _OPENMP
#include <omp.h>
#else
int omp_get_num_teams() {return 1;}
int omp_get_num_threads() {return 1;}
#endif
bool almost_equal(float x, float gold, float tol) {
  if ( std::signbit(x) != std::signbit(gold) )
  {
    x = std::abs(gold) - std::abs(x);
  }
  return std::abs(gold) * (1-tol) <= std::abs(x) && std::abs(x) <= std::abs(gold) * (1 + tol);
}
void test_target__teams__parallel__simd() {
  const int N0 { 32768 };
  const float expected_value { N0 };
  float counter_teams{};
  #pragma omp target map(tofrom: counter_teams)
  #pragma omp teams
  {
    #pragma omp parallel
    {
      #pragma omp simd
      for (int i0 = 0 ; i0 < N0 ; i0++ )
      {
        #pragma omp atomic update
        counter_teams = counter_teams + float { float{ 1. } / ( omp_get_num_teams() * omp_get_num_threads() ) };
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
    test_target__teams__parallel__simd();
}
