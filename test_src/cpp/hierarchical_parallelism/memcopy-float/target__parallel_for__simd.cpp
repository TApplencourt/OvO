#include <iostream>
#include <limits>
#include <cmath>
#include <vector>
#include <algorithm>
bool almost_equal(float x, float y, int ulp) {
     return std::fabs(x-y) <= std::numeric_limits<float>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<float>::min();
}
void test_target__parallel_for__simd(){
  const int N0 = 512;
  const int N1 = 512;
  const int size = N0*N1;
  std::vector<float> A(size);
  std::vector<float> B(size);
  std::generate(B.begin(), B.end(), std::rand);
  float *pA = A.data();
  float *pB = B.data();
#pragma omp target   map(from: pA[0:N0*N1]) map(to: pB[0:N0*N1])
#pragma omp parallel for
      for (int i0 = 0 ; i0 < N0 ; i0++ )
      {
#pragma omp simd
      for (int i0 = 0 ; i0 < N0 ; i0++ )
      {
const int idx = i1+i0*N1;
pA[idx] = pB[idx];
    }
    }
for (int i = 0 ;  i < size ; i++) {
    if ( !almost_equal(A[i],B[i],1) ) {
         std::cerr << "Expected: " << B[i] << " Got: " << A[i] << std::endl;
        std::exit(112);
    }
}
}
int main()
{
    test_target__parallel_for__simd();
}
