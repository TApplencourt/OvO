#include <iostream>
#include <cstdlib>
#include <cmath>
#include <limits>
#include <vector>
#include <algorithm>
bool almost_equal(float x, float y, int ulp) {
  return std::fabs(x-y) <= std::numeric_limits<float>::epsilon() * std::fabs(x+y) * ulp || std::fabs(x-y) < std::numeric_limits<float>::min();
}
void test_target_parallel__for() {
  const int N0 { 32768 };
  const int size = N0;
  std::vector<float> dst(size), src(size);
  std::generate(src.begin(), src.end(), std::rand);
  float *pS { src.data() };
  float *pD { dst.data() };
  #pragma omp target parallel map(to: pS[0:size]) map(from: pD[0:size])
  #pragma omp for
  for (int i0 = 0 ; i0 < N0 ; i0++ )
  {
    const int idx = i0;
    pD[idx] = pS[idx];
  }
  for (int i = 0 ; i < size ; i++)
    if ( !almost_equal(dst[i],src[i],1) ) {
      std::cerr << "Expected: " << src[i] << " Got: " << dst[i] << std::endl;
      std::exit(112);
  }
}
int main()
{
    test_target_parallel__for();
}
