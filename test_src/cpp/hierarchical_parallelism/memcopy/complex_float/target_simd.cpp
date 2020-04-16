#include <iostream>
#include <limits>
#include <cmath>

#include <complex>
using namespace std;

#include <vector>
#include <algorithm>
#include <stdexcept>
    
bool almost_equal(complex<float> x, complex<float> y, int ulp) {

    bool r = std::fabs(x.real()-y.real()) <= std::numeric_limits<float>::epsilon() * std::fabs(x.real()+y.real()) * ulp ||  std::fabs(x.real()-y.real()) < std::numeric_limits<float>::min();
    bool i = std::fabs(x.imag()-y.imag()) <= std::numeric_limits<float>::epsilon() * std::fabs(x.imag()+y.imag()) * ulp ||  std::fabs(x.imag()-y.imag()) < std::numeric_limits<float>::min();
    return r && i;

}

void test_target_simd(){
  // Input and Outputs
  
  const int L = 5;
  const int size = L;
  std::vector<complex<float>> A(size);
  std::vector<complex<float>> B(size);
  std::generate(B.begin(), B.end(), std::rand);

  complex<float> *pA = A.data();
  complex<float> *pB = B.data();

// Main program

#pragma omp target simd   map(from: pA[0:L]) map(to: pB[0:L]) 

    for (int i = 0 ; i < L ; i++ )

{


pA[ i ] = pB [ i ];

 } 

// Validation
for (int i = 0 ;  i < size ; i++) {
    if ( !almost_equal(A[i],B[i],1) ) {
         std::cerr << "Expected: " << B[i] << " Got: " << A[i] << std::endl;
        throw std::runtime_error( "target_simd give incorect value when offloaded");
    }
}
 
}

int main()
{
    test_target_simd();
}