#include <iostream>
#include <cstdlib>
#include <cmath>
bool almost_equal(float x, float gold, float tol) {
  return gold * (1-tol) <= x && x <= gold * (1 + tol);
}
void test_target_teams__distribute__parallel__for() {
  const int N0 { 512 };
  const int N1 { 512 };
  const float expected_value { N0*N1 };
  float counter_N0{};
  #pragma omp target teams map(tofrom: counter_N0)
  #pragma omp distribute
  for (int i0 = 0 ; i0 < N0 ; i0++ )
  {
    float counter_N1{};
    #pragma omp parallel
    #pragma omp for
    for (int i1 = 0 ; i1 < N1 ; i1++ )
    {
      #pragma omp atomic update
      counter_N1 = counter_N1 +  1. ;
    }
    #pragma omp atomic update
    counter_N0 = counter_N0 +  counter_N1 ;
  }
  if (!almost_equal(counter_N0, expected_value, 0.1)) {
    std::cerr << "Expected: " << expected_value << " Got: " << counter_N0 << std::endl;
    std::exit(112);
  }
}
int main()
{
    test_target_teams__distribute__parallel__for();
}
