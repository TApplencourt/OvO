#include <iostream>
#include <limits>
#include <cmath>
#include <complex>
using namespace std;
#include <vector>
#include <algorithm>
#include <stdexcept>
bool almost_equal(complex<double> x, complex<double> y, int ulp) {
    return std::abs(x-y) <= std::numeric_limits<>::epsilon() * std::abs(x+y) * ulp ||  std::abs(x-y) < std::numeric_limits<>::min();
}
void test_target__teams_distribute__parallel__for__simd(){
  // Input and Outputs
  const int L = 64;
  const int M = 64;
  const int N = 64;
  const int size = L*M*N;
  std::vector<complex<double>> A(size);
  std::vector<complex<double>> B(size);
  std::generate(B.begin(), B.end(), std::rand);
  complex<double> *pA = A.data();
  complex<double> *pB = B.data();
// Main program
#pragma omp target   map(from: pA[0:L*M*N]) map(to: pB[0:L*M*N]) 
#pragma omp teams distribute 
    for (int i = 0 ; i < L ; i++ )
    {
#pragma omp parallel 
#pragma omp for 
    for (int j = 0 ; j < M ; j++ )
    {
#pragma omp simd 
    for (int k = 0 ; k < N ; k++ )
    {
pA[ k + j*N + i*N*M ] = pB [ k + j*N + i*N*M ];
    } 
    } 
    } 
// Validation
for (int i = 0 ;  i < size ; i++) {
    if ( !almost_equal(A[i],B[i],1) ) {
         std::cerr << "Expected: " << B[i] << " Got: " << A[i] << std::endl;
        throw std::runtime_error( "target__teams_distribute__parallel__for__simd give incorect value when offloaded");
    }
}
}
int main()
{
    test_target__teams_distribute__parallel__for__simd();
}