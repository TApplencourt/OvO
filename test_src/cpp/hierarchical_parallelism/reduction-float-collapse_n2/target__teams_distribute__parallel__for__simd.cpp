#include <iostream>
#include <cstdlib>
#include <cmath>
bool almost_equal(float x, float gold, float tol) {
  return gold * (1-tol) <= x && x <= gold * (1 + tol);
}
void test_target__teams_distribute__parallel__for__simd() {
  const int N0 { 8 };
  const int N1 { 8 };
  const int N2 { 8 };
  const int N3 { 8 };
  const int N4 { 8 };
  const int N5 { 8 };
  const float expected_value { N0*N1*N2*N3*N4*N5 };
  float counter_N0{};
  #pragma omp target map(tofrom: counter_N0)
  #pragma omp teams distribute reduction(+: counter_N0) collapse(2)
  for (int i0 = 0 ; i0 < N0 ; i0++ )
  for (int i1 = 0 ; i1 < N1 ; i1++ )
  {
    #pragma omp parallel reduction(+: counter_N0)
    #pragma omp for collapse(2)
    for (int i2 = 0 ; i2 < N2 ; i2++ )
    for (int i3 = 0 ; i3 < N3 ; i3++ )
    {
      #pragma omp simd reduction(+: counter_N0) collapse(2)
      for (int i4 = 0 ; i4 < N4 ; i4++ )
      for (int i5 = 0 ; i5 < N5 ; i5++ )
      {
        counter_N0 = counter_N0 +  1. ;
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
    test_target__teams_distribute__parallel__for__simd();
}
