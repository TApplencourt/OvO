#include <iostream>
#include <cstdlib>
#include <cmath>
#include <complex>
using namespace std;
bool almost_equal(complex<double> x, complex<double> gold, float tol) {
        return abs(gold) * (1-tol) <= abs(x) && abs(x) <= abs(gold) * (1 + tol);
}
#pragma omp declare reduction(+: complex<double>: omp_out += omp_in)
void test_target__teams_distribute_parallel_for(){
 const int N0 = 262144;
 complex<double> counter{};
#pragma omp target map(tofrom: counter)
#pragma omp teams distribute parallel for reduction(+: counter)
      for (int i0 = 0 ; i0 < N0 ; i0++ )
      {
counter += complex<double> { 1.0f };
    }
if ( !almost_equal(counter,complex<double> { N0 }, 0.1)  ) {
    std::cerr << "Expected: " << N0 << " Got: " << counter << std::endl;
    std::exit(112);
}
}
int main()
{
    test_target__teams_distribute_parallel_for();
}
