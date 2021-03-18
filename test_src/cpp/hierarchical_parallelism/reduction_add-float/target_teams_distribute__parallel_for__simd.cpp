#include <iostream>
#include <cstdlib>
#include <cmath>
bool almost_equal(float x, float gold, float tol) {
  if ( std::signbit(x) != std::signbit(gold) )
  {
    x = std::abs(gold) - std::abs(x);
  }
  return std::abs(gold) * (1-tol) <= std::abs(x) && std::abs(x) <= std::abs(gold) * (1 + tol);
}
void test_target_teams_distribute__parallel_for__simd() {
  const int N0 { 32 };
  const int N1 { 32 };
  const int N2 { 32 };
  const float expected_value { N0*N1*N2 };
  float counter_N0{};
  #pragma omp target teams distribute reduction(+: counter_N0)
  for (int i0 = 0 ; i0 < N0 ; i0++ )
  {
    #pragma omp parallel for reduction(+: counter_N0)
    for (int i1 = 0 ; i1 < N1 ; i1++ )
    {
      #pragma omp simd reduction(+: counter_N0)
      for (int i2 = 0 ; i2 < N2 ; i2++ )
      {
        counter_N0 = counter_N0 + 1. ;
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
    test_target_teams_distribute__parallel_for__simd();
}
