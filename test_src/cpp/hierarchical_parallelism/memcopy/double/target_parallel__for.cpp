#include <iostream>
#include <limits>


#include <vector>
#include <algorithm>

bool almost_equal(double x, double y, int ulp) {

     return std::fabs(x-y) <= std::numeric_limits<double>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<double>::min();

}

void test_target_parallel__for(){
  // Input and Outputs
  
  const int L = 5;
  const int size = L;
  std::vector<double> A(size);
  std::vector<double> B(size);
  std::generate(B.begin(), B.end(), std::rand);

  double *pA = A.data();
  double *pB = B.data();

// Main program

#pragma omp target parallel   map(from: pA[0:L]) map(to: pB[0:L]) 

{

#pragma omp for 

    for (int i = 0 ; i < L ; i++ )

{


pA[ i ] = pB [ i ];

 }  } 

// Validation
for (int i = 0 ;  i < size ; i++) {
    if ( !almost_equal(A[i],B[i],1) ) {
         std::cerr << "Expected: " << B[i] << " Got: " << A[i] << std::endl;
        throw std::runtime_error( "target_parallel__for give incorect value when offloaded");
    }
}
 
}

int main()
{
    test_target_parallel__for();
}