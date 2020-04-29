#include <iostream>
#include <cstdlib>
#include <cmath>
#include <complex>
using namespace std;
bool almost_equal(complex<double> x, complex<double> gold, float tol) {
        return abs(gold) * (1-tol) <= abs(x) && abs(x) <= abs(gold) * (1 + tol);
}
#pragma omp declare reduction(+: complex<double>: omp_out += omp_in)
void test_target_teams_distribute_simd(){
 const int L = 262144;
 complex<double> counter{};
#pragma omp target teams distribute simd reduction(+: counter) map(tofrom:counter) 
    for (int i = 0 ; i < L ; i++ )
    {
counter += complex<double> { 1.0f };
    }
if ( !almost_equal(counter,complex<double> { L }, 0.1)  ) {
    std::cerr << "Expected: " << L << " Got: " << counter << std::endl;
    std::exit(112);
}
}
int main()
{
    test_target_teams_distribute_simd();
}
