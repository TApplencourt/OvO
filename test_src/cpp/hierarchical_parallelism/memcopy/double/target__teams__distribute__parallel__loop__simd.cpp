#include <iostream>
#include <limits>
#include <cmath>

#include <vector>
#include <algorithm>
#include <stdexcept>
    
bool almost_equal(double x, double y, int ulp) {

     return std::fabs(x-y) <= std::numeric_limits<double>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<double>::min();

}

void test_target__teams__distribute__parallel__loop__simd(){
  // Input and Outputs
  
  const int L = 5;
  const int M = 6;
  const int N = 7;
  const int size = L*M*N;
  std::vector<double> A(size);
  std::vector<double> B(size);
  std::generate(B.begin(), B.end(), std::rand);

  double *pA = A.data();
  double *pB = B.data();

// Main program

#pragma omp target   map(from: pA[0:L*M*N]) map(to: pB[0:L*M*N]) 

{

#pragma omp teams 

{

#pragma omp distribute 

    for (int i = 0 ; i < L ; i++ )

{

#pragma omp parallel 

{

#pragma omp loop 

    for (int j = 0 ; j < M ; j++ )

{

#pragma omp simd 

    for (int k = 0 ; k < N ; k++ )

{


pA[ k + j*N + i*N*M ] = pB [ k + j*N + i*N*M ];

 }  }  }  }  }  } 

// Validation
for (int i = 0 ;  i < size ; i++) {
    if ( !almost_equal(A[i],B[i],1) ) {
         std::cerr << "Expected: " << B[i] << " Got: " << A[i] << std::endl;
        throw std::runtime_error( "target__teams__distribute__parallel__loop__simd give incorect value when offloaded");
    }
}
 
}

int main()
{
    test_target__teams__distribute__parallel__loop__simd();
}