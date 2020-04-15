#include <iostream>
#include <limits>
#include <cmath>

#include <vector>
#include <algorithm>

bool almost_equal(float x, float y, int ulp) {

     return std::fabs(x-y) <= std::numeric_limits<float>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<float>::min();

}

void test_target_teams_loop__parallel_loop.cpp(){
  // Input and Outputs
  
  const int L = 5;
  const int M = 6;
  const int size = L*M;
  std::vector<float> A(size);
  std::vector<float> B(size);
  std::generate(B.begin(), B.end(), std::rand);

  float *pA = A.data();
  float *pB = B.data();

// Main program

#pragma omp target teams loop   map(from: pA[0:L*M]) map(to: pB[0:L*M]) 

    for (int i = 0 ; i < L ; i++ )

{

#pragma omp parallel loop 

    for (int j = 0 ; j < M ; j++ )

{


pA[ j + i*M ] = pB [ j + i*M ];

 }  } 

// Validation
for (int i = 0 ;  i < size ; i++) {
    if ( !almost_equal(A[i],B[i],1) ) {
         std::cerr << "Expected: " << B[i] << " Got: " << A[i] << std::endl;
        throw std::runtime_error( "target_teams_loop__parallel_loop.cpp give incorect value when offloaded");
    }
}
 
}

int main()
{
    test_target_teams_loop__parallel_loop.cpp();
}