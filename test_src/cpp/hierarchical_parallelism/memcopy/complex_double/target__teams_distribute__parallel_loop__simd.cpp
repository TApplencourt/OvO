#include <iostream>
#include <limits>
#include <cmath>

#include <complex>
using namespace std;

#include <vector>
#include <algorithm>

bool almost_equal(complex<double> x, complex<double> y, int ulp) {

    bool r = std::fabs(x.real()-y.real()) <= std::numeric_limits<double>::epsilon() * std::fabs(x.real()+y.real()) * ulp ||  std::fabs(x.real()-y.real()) < std::numeric_limits<double>::min();
    bool i = std::fabs(x.imag()-y.imag()) <= std::numeric_limits<double>::epsilon() * std::fabs(x.imag()+y.imag()) * ulp ||  std::fabs(x.imag()-y.imag()) < std::numeric_limits<double>::min();
    return r && i;

}

void test_target__teams_distribute__parallel_loop__simd.cpp(){
  // Input and Outputs
  
  const int L = 5;
  const int M = 6;
  const int N = 7;
  const int size = L*M*N;
  std::vector<complex<double>> A(size);
  std::vector<complex<double>> B(size);
  std::generate(B.begin(), B.end(), std::rand);

  complex<double> *pA = A.data();
  complex<double> *pB = B.data();

// Main program

#pragma omp target   map(from: pA[0:L*M*N]) map(to: pB[0:L*M*N]) 

{

#pragma omp teams distribute 

    for (int i = 0 ; i < L ; i++ )

{

#pragma omp parallel loop 

    for (int j = 0 ; j < M ; j++ )

{

#pragma omp simd 

    for (int k = 0 ; k < N ; k++ )

{


pA[ k + j*N + i*N*M ] = pB [ k + j*N + i*N*M ];

 }  }  }  } 

// Validation
for (int i = 0 ;  i < size ; i++) {
    if ( !almost_equal(A[i],B[i],1) ) {
         std::cerr << "Expected: " << B[i] << " Got: " << A[i] << std::endl;
        throw std::runtime_error( "target__teams_distribute__parallel_loop__simd.cpp give incorect value when offloaded");
    }
}
 
}

int main()
{
    test_target__teams_distribute__parallel_loop__simd.cpp();
}