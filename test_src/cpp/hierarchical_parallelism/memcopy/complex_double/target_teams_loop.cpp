#include <iostream>
#include <limits>
#include <cmath>
#include <complex>
using namespace std;
#include <vector>
#include <algorithm>
#include <stdexcept>
bool almost_equal(complex<double> x, complex<double> y, int ulp) {
    return std::abs(x-y) <= std::numeric_limits<double>::epsilon() * std::abs(x+y) * ulp ||  std::abs(x-y) < std::numeric_limits<double>::min();
}
void test_target_teams_loop(){
  // Input and Outputs
  const int L = 262144;
  const int size = L;
  std::vector<complex<double>> A(size);
  std::vector<complex<double>> B(size);
  std::generate(B.begin(), B.end(), std::rand);
  complex<double> *pA = A.data();
  complex<double> *pB = B.data();
// Main program
#pragma omp target teams loop   map(from: pA[0:L]) map(to: pB[0:L]) 
    for (int i = 0 ; i < L ; i++ )
    {
pA[ i ] = pB [ i ];
    } 
// Validation
for (int i = 0 ;  i < size ; i++) {
    if ( !almost_equal(A[i],B[i],1) ) {
         std::cerr << "Expected: " << B[i] << " Got: " << A[i] << std::endl;
        throw std::runtime_error( "target_teams_loop give incorect value when offloaded");
    }
}
}
int main()
{
    test_target_teams_loop();
}
