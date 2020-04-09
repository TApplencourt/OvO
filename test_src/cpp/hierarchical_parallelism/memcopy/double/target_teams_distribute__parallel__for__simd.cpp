#include <cassert>
#include <cmath>
#include <limits>
#include <iomanip>
#include <iostream>
#include <type_traits>
#include <algorithm>
#include <vector>

template<class T>
typename std::enable_if<!std::numeric_limits<T>::is_integer, bool>::type
    almost_equal(T x, T y)
{
    //Let say 2 ulp is good enough...
	  int ulp = 2;
    // the machine epsilon has to be scaled to the magnitude of the values used
    // and multiplied by the desired precision in ULPs (units in the last place)
    return std::fabs(x-y) <= std::numeric_limits<T>::epsilon() * std::fabs(x+y) * ulp
        // unless the result is subnormal
        || std::fabs(x-y) < std::numeric_limits<T>::min();
}

template<class T>
void test_target_teams_distribute__parallel__for__simd(){
  // Input and Outputs
  
  const int L = 5;
  const int M = 6;
  const int N = 7;
  const int size = L*M*N;
  std::vector<T> A(size);
  std::vector<T> B(size);
  std::generate(B.begin(), B.end(), std::rand);

  T *pA = A.data();
  T *pB = B.data();

// Main program

#pragma omp target teams distribute   map(from: pA[0:L*M*N]) map(to: pB[0:L*M*N]) 

    for (int i = 0 ; i < L ; i++ )

{

#pragma omp parallel 

{

#pragma omp for 

    for (int j = 0 ; j < M ; j++ )

{

#pragma omp simd 

    for (int k = 0 ; k < N ; k++ )

{


pA[ k + j*N + i*N*M ] = pB [ k + j*N + i*N*M ];

 }  }  }  } 

// Validation
assert(std::equal(A.begin(), A.end(), B.begin(), almost_equal<T>));
 
}

int main()
{
    test_target_teams_distribute__parallel__for__simd<double>();
}