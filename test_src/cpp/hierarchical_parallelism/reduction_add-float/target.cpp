#include <iostream>
#include <cstdlib>
#include <cmath>
bool almost_equal(float x, float gold, float rel_tol=1e-09, float abs_tol=0.0) {
  return std::abs(x-gold) <= std::max(rel_tol * std::max(std::abs(x), std::abs(gold)), abs_tol);
}
void test_target() {
  const float expected_value { 1 };
  float counter_target{};
  #pragma omp target map(tofrom: counter_target)
  {
    counter_target = counter_target + 1. ;
  }
  if (!almost_equal(counter_target, expected_value, 0.1)) {
    std::cerr << "Expected: " << expected_value << " Got: " << counter_target << std::endl;
    std::exit(112);
  }
}
int main()
{
    test_target();
}
