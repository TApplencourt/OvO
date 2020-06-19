#include <iostream>
#include <cstdlib>
#include <cmath>
bool almost_equal(float x, float gold, float tol) {
  return gold * (1-tol) <= x && x <= gold * (1 + tol);
}
void test_target__parallel__for() {
  const int N0 { 512 };
  const int N1 { 512 };
  const float expected_value { N0*N1 };
  float counter_N0{};
  #pragma omp target map(tofrom: counter_N0)
  #pragma omp parallel
  #pragma omp for collapse(2)
  for (int i0 = 0 ; i0 < N0 ; i0++ )
  for (int i1 = 0 ; i1 < N1 ; i1++ )
  {
    #pragma omp atomic update
    counter_N0 = counter_N0 +  1. ;
  }
  if (!almost_equal(counter_N0, expected_value, 0.1)) {
    std::cerr << "Expected: " << expected_value << " Got: " << counter_N0 << std::endl;
    std::exit(112);
  }
}
int main()
{
    test_target__parallel__for();
}
