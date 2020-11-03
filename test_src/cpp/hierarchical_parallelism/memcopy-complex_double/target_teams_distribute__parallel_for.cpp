#include <iostream>
#include <cstdlib>
#include <cmath>
#include <limits>
#include <vector>
#include <algorithm>
#include <complex>
using std::complex;
bool almost_equal(complex<double> x, complex<double> y, int ulp) {
  return std::abs(x-y) <= std::numeric_limits<double>::epsilon() * std::abs(x+y) * ulp ||  std::abs(x-y) < std::numeric_limits<double>::min();
}
void test_target_teams_distribute__parallel_for() {
  const int N0 { 182 };
  const int N1 { 182 };
  const int size = N0*N1;
  std::vector<complex<double>> dst(size), src(size);
  std::generate(src.begin(), src.end(), std::rand);
  complex<double> *pS { src.data() };
  complex<double> *pD { dst.data() };
  #pragma omp target teams distribute map(to: pS[0:size]) map(from: pD[0:size])
  for (int i0 = 0 ; i0 < N0 ; i0++ )
  {
    #pragma omp parallel for
    for (int i1 = 0 ; i1 < N1 ; i1++ )
    {
      const int idx = i1+N1*(i0);
      pD[idx] = pS[idx];
    }
  }
  for (int i = 0 ;  i < size ; i++)
    if ( !almost_equal(dst[i],src[i],1) ) {
      std::cerr << "Expected: " << src[i] << " Got: " << dst[i] << std::endl;
      std::exit(112);
  }
}
int main()
{
    test_target_teams_distribute__parallel_for();
}
