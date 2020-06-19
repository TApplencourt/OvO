#include <iostream>
#include <cstdlib>
#include <cmath>
#ifdef _OPENMP
#include <omp.h>
#else
int omp_get_num_threads() {return 1;}
#endif
bool almost_equal(float x, float gold, float tol) {
  return gold * (1-tol) <= x && x <= gold * (1 + tol);
}
void test_target_teams_distribute__parallel() {
  const int N0 { 262144 };
  const float expected_value { N0 };
  float counter_N0{};
  #pragma omp target teams distribute map(tofrom: counter_N0)
  for (int i0 = 0 ; i0 < N0 ; i0++ )
  {
    float counter_parallel{};
    #pragma omp parallel
    {
      #pragma omp atomic update
      counter_parallel = counter_parallel + float { float { 1. } / omp_get_num_threads() };
    }
    #pragma omp atomic update
    counter_N0 = counter_N0 +  counter_parallel ;
  }
  if (!almost_equal(counter_N0, expected_value, 0.1)) {
    std::cerr << "Expected: " << expected_value << " Got: " << counter_N0 << std::endl;
    std::exit(112);
  }
}
int main()
{
    test_target_teams_distribute__parallel();
}
