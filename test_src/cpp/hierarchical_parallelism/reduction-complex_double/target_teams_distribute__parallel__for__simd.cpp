#include <iostream>
#include <cstdlib>
#include <cmath>
#include <complex>
using namespace std;
bool almost_equal(complex<double> x, complex<double> gold, float tol) {
        return abs(gold) * (1-tol) <= abs(x) && abs(x) <= abs(gold) * (1 + tol);
}
#pragma omp declare reduction(+: complex<double>: omp_out += omp_in)
void test_target_teams_distribute__parallel__for__simd(){
 const int N0 = 64;
 const int N1 = 64;
 const int N2 = 64;
 complex<double> counter{};
#pragma omp target teams distribute reduction(+: counter) map(tofrom: counter)
      for (int i0 = 0 ; i0 < N0 ; i0++ )
      {
#pragma omp parallel reduction(+: counter)
#pragma omp for
      for (int i0 = 0 ; i0 < N0 ; i0++ )
      {
#pragma omp simd reduction(+: counter)
      for (int i0 = 0 ; i0 < N0 ; i0++ )
      {
counter += complex<double> { 1.0f };
    }
    }
    }
if ( !almost_equal(counter,complex<double> { N0*N1*N2 }, 0.1)  ) {
    std::cerr << "Expected: " << N0*N1*N2 << " Got: " << counter << std::endl;
    std::exit(112);
}
}
int main()
{
    test_target_teams_distribute__parallel__for__simd();
}
