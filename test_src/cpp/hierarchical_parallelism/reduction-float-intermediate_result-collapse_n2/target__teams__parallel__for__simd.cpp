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
void test_target__teams__parallel__for__simd() {
  const int N0 { 23 };
  const int N1 { 23 };
  const int N2 { 23 };
  const int N3 { 23 };
  const float expected_value { N0*N1*N2*N3 };
  float counter_teams{};
  #pragma omp target map(tofrom: counter_teams)
  #pragma omp teams reduction(+: counter_teams)
  {
    float counter_N0{};
    #pragma omp parallel reduction(+: counter_N0)
    #pragma omp for collapse(2)
    for (int i0 = 0 ; i0 < N0 ; i0++ )
    for (int i1 = 0 ; i1 < N1 ; i1++ )
    {
      float counter_N2{};
      #pragma omp simd reduction(+: counter_N2) collapse(2)
      for (int i2 = 0 ; i2 < N2 ; i2++ )
      for (int i3 = 0 ; i3 < N3 ; i3++ )
      {
        counter_N2 = counter_N2 +  1. ;
      }
      counter_N0 = counter_N0 +  counter_N2 ;
    }
    counter_teams = counter_teams +  counter_N0 ;
  }
  if (!almost_equal(counter_teams, expected_value, 0.1)) {
    std::cerr << "Expected: " << expected_value << " Got: " << counter_teams << std::endl;
    std::exit(112);
  }
}
int main()
{
    test_target__teams__parallel__for__simd();
}
