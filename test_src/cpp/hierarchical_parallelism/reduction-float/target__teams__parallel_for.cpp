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
void test_target__teams__parallel_for() {
  const int N0 { 32768 };
  const float expected_value { N0 };
  float counter_teams{};
  #pragma omp target map(tofrom: counter_teams)
  #pragma omp teams reduction(+: counter_teams)
  {
    #pragma omp parallel for reduction(+: counter_teams)
    for (int i0 = 0 ; i0 < N0 ; i0++ )
    {
      counter_teams = counter_teams + float { float{ 1. } / omp_get_num_teams() };
    }
  }
  if (!almost_equal(counter_teams, expected_value, 0.1)) {
    std::cerr << "Expected: " << expected_value << " Got: " << counter_teams << std::endl;
    std::exit(112);
  }
}
int main()
{
    test_target__teams__parallel_for();
}
