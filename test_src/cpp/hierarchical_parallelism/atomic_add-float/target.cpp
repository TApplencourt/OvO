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
void test_target() {
  const float expected_value { 1 };
  float counter_target{};
  #pragma omp target map(tofrom: counter_target)
  {
    #pragma omp atomic update
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
