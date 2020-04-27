#include <iostream>
#include <limits>
#include <cmath>
#include <vector>
#include <algorithm>
#include <stdexcept>
bool almost_equal(float x, float y, int ulp) {
     return std::fabs(x-y) <= std::numeric_limits<float>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<float>::min();
}
void test_target__parallel_for_simd(){
  // Input and Outputs
  const int L = 262144;
  const int size = L;
  std::vector<float> A(size);
  std::vector<float> B(size);
  std::generate(B.begin(), B.end(), std::rand);
  float *pA = A.data();
  float *pB = B.data();
// Main program
#pragma omp target   map(from: pA[0:L]) map(to: pB[0:L]) 
#pragma omp parallel for simd 
    for (int i = 0 ; i < L ; i++ )
    {
pA[ i ] = pB [ i ];
    } 
// Validation
for (int i = 0 ;  i < size ; i++) {
    if ( !almost_equal(A[i],B[i],1) ) {
         std::cerr << "Expected: " << B[i] << " Got: " << A[i] << std::endl;
        throw std::runtime_error( "target__parallel_for_simd give incorect value when offloaded");
    }
}
}
int main()
{
    test_target__parallel_for_simd();
}
