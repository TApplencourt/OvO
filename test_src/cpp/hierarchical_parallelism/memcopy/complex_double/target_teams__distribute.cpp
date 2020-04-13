#include <iostream>
#include <limits>


#include <complex>
using namespace std;

#include <vector>
#include <algorithm>

bool almost_equal(complex<double> x, complex<double> y, int ulp) {

    bool r = std::fabs(x.real()-y.real()) <= std::numeric_limits<double>::epsilon() * std::fabs(x.real()+y.real()) * ulp ||  std::fabs(x.real()-y.real()) < std::numeric_limits<double>::min();
    bool i = std::fabs(x.imag()-y.imag()) <= std::numeric_limits<double>::epsilon() * std::fabs(x.imag()+y.imag()) * ulp ||  std::fabs(x.imag()-y.imag()) < std::numeric_limits<double>::min();
    return r && i;

}

void test_target_teams__distribute(){
  // Input and Outputs
  
  const int L = 5;
  const int size = L;
  std::vector<complex<double>> A(size);
  std::vector<complex<double>> B(size);
  std::generate(B.begin(), B.end(), std::rand);

  complex<double> *pA = A.data();
  complex<double> *pB = B.data();

// Main program

#pragma omp target teams   map(from: pA[0:L]) map(to: pB[0:L]) 

{

#pragma omp distribute 

    for (int i = 0 ; i < L ; i++ )

{


pA[ i ] = pB [ i ];

 }  } 

// Validation
for (int i = 0 ;  i < size ; i++) {
    if ( !almost_equal(A[i],B[i],1) ) {
         std::cerr << "Expected: " << B[i] << " Got: " << A[i] << std::endl;
        throw std::runtime_error( "target_teams__distribute give incorect value when offloaded");
    }
}
 
}

int main()
{
    test_target_teams__distribute();
}