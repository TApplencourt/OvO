#include <iostream>
#include <limits>
#include <cmath>
#include <vector>
#include <algorithm>
bool almost_equal(float x, float y, int ulp) {
     return std::fabs(x-y) <= std::numeric_limits<float>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<float>::min();
}
void test_target__teams_distribute__parallel_for__simd(){
  const int N0 = 64;
  const int N1 = 64;
  const int N2 = 64;
  const int size = N0*N1*N2;
  std::vector<float> A(size);
  std::vector<float> B(size);
  std::generate(B.begin(), B.end(), std::rand);
  float *pA = A.data();
  float *pB = B.data();
#pragma omp target   map(from: pA[0:size]) map(to: pB[0:size])
#pragma omp teams distribute
      for (int i0 = 0 ; i0 < N0 ; i0++ )
      {
#pragma omp parallel for
      for (int i1 = 0 ; i1 < N1 ; i1++ )
      {
#pragma omp simd
      for (int i2 = 0 ; i2 < N2 ; i2++ )
      {
const int idx = i2+(i1+(i0*N1)*N2);
pA[idx] = pB[idx];
    }
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
    test_target__teams_distribute__parallel_for__simd();
}
