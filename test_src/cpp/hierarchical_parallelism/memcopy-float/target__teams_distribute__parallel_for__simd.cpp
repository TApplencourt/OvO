#include <iostream>
#include <cstdlib>
#include <cmath>
#include <limits>
#include <vector>
#include <algorithm>
bool almost_equal(float x, float y, int ulp) {
  return std::fabs(x-y) <= std::numeric_limits<float>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<float>::min();
}
void test_target__teams_distribute__parallel_for__simd() {
  const int N0 { 32 };
  const int N1 { 32 };
  const int N2 { 32 };
  const int size = N0*N1*N2;
  std::vector<float> dst(size), src(size);
  std::generate(src.begin(), src.end(), std::rand);
  float *pS { src.data() };
  float *pD { dst.data() };
  #pragma omp target map(to: pS[0:size]) map(from: pD[0:size])
  #pragma omp teams distribute
  for (int i0 = 0 ; i0 < N0 ; i0++ )
  {
    #pragma omp parallel for
    for (int i1 = 0 ; i1 < N1 ; i1++ )
    {
      #pragma omp simd
      for (int i2 = 0 ; i2 < N2 ; i2++ )
      {
        const int idx = i2+N2*(i1+N1*(i0));
        pD[idx] = pS[idx];
      }
    }
  }
  for (int i = 0 ;  i < size ; i++)
    if ( !almost_equal(dst[i],src[i],1) ) {
      std::cerr << "Expected: " << dst[i] << " Got: " << src[i] << std::endl;
      std::exit(112);
  }
}
int main()
{
    test_target__teams_distribute__parallel_for__simd();
}
