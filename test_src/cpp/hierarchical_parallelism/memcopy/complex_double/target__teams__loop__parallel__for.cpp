#include <iostream>
#include <limits>
#include <cmath>
#include <complex>
using namespace std;
#include <vector>
#include <algorithm>
#include <stdexcept>
bool almost_equal(complex<double> x, complex<double> y, int ulp) {
    bool r = std::fabs(x.real()-y.real()) <= std::numeric_limits<double>::epsilon() * std::fabs(x.real()+y.real()) * ulp ||  std::fabs(x.real()-y.real()) < std::numeric_limits<double>::min();
    bool i = std::fabs(x.imag()-y.imag()) <= std::numeric_limits<double>::epsilon() * std::fabs(x.imag()+y.imag()) * ulp ||  std::fabs(x.imag()-y.imag()) < std::numeric_limits<double>::min();
    return r && i;
}
void test_target__teams__loop__parallel__for(){
  // Input and Outputs
  const int L = 4096;
  const int M = 64;
  const int size = L*M;
  std::vector<complex<double>> A(size);
  std::vector<complex<double>> B(size);
  std::generate(B.begin(), B.end(), std::rand);
  complex<double> *pA = A.data();
  complex<double> *pB = B.data();
// Main program
#pragma omp target   map(from: pA[0:L*M]) map(to: pB[0:L*M]) 
#pragma omp teams 
#pragma omp loop 
    for (int i = 0 ; i < L ; i++ )
    {
#pragma omp parallel 
#pragma omp for 
    for (int j = 0 ; j < M ; j++ )
    {
pA[ j + i*M ] = pB [ j + i*M ];
    } 
    } 
// Validation
for (int i = 0 ;  i < size ; i++) {
    if ( !almost_equal(A[i],B[i],1) ) {
         std::cerr << "Expected: " << B[i] << " Got: " << A[i] << std::endl;
        throw std::runtime_error( "target__teams__loop__parallel__for give incorect value when offloaded");
    }
}
}
int main()
{
    test_target__teams__loop__parallel__for();
}
