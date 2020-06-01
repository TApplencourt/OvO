#include <iostream>
#include <limits>
#include <cmath>
#include <complex>
using namespace std;
#include <vector>
#include <algorithm>
#include <stdexcept>
bool almost_equal(complex<float> x, complex<float> y, int ulp) {
    return std::abs(x-y) <= std::numeric_limits<>::epsilon() * std::abs(x+y) * ulp ||  std::abs(x-y) < std::numeric_limits<>::min();
}
void test_target_teams__distribute__parallel_for(){
  // Input and Outputs
  const int L = 4096;
  const int M = 64;
  const int size = L*M;
  std::vector<complex<float>> A(size);
  std::vector<complex<float>> B(size);
  std::generate(B.begin(), B.end(), std::rand);
  complex<float> *pA = A.data();
  complex<float> *pB = B.data();
// Main program
#pragma omp target teams   map(from: pA[0:L*M]) map(to: pB[0:L*M]) 
#pragma omp distribute 
    for (int i = 0 ; i < L ; i++ )
    {
#pragma omp parallel for 
    for (int j = 0 ; j < M ; j++ )
    {
pA[ j + i*M ] = pB [ j + i*M ];
    } 
    } 
// Validation
for (int i = 0 ;  i < size ; i++) {
    if ( !almost_equal(A[i],B[i],1) ) {
         std::cerr << "Expected: " << B[i] << " Got: " << A[i] << std::endl;
        throw std::runtime_error( "target_teams__distribute__parallel_for give incorect value when offloaded");
    }
}
}
int main()
{
    test_target_teams__distribute__parallel_for();
}
