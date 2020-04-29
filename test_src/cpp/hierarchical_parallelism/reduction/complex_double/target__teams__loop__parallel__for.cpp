#include <iostream>
#include <cstdlib>
#include <cmath>
#include <complex>
using namespace std;
bool almost_equal(complex<double> x, complex<double> gold, float tol) {
        return abs(gold) * (1-tol) <= abs(x) && abs(x) <= abs(gold) * (1 + tol);
}
#pragma omp declare reduction(+: complex<double>: omp_out += omp_in)
void test_target__teams__loop__parallel__for(){
 const int L = 4096;
 const int M = 64;
 complex<double> counter{};
#pragma omp target map(tofrom:counter) 
#pragma omp teams reduction(+: counter)
#pragma omp loop
    for (int i = 0 ; i < L ; i++ )
    {
#pragma omp parallel reduction(+: counter)
#pragma omp for
    for (int j = 0 ; j < M ; j++ )
    {
counter += complex<double> { 1.0f };
    }
    }
if ( !almost_equal(counter,complex<double> { L*M }, 0.1)  ) {
    std::cerr << "Expected: " << L*M << " Got: " << counter << std::endl;
    std::exit(112);
}
}
int main()
{
    test_target__teams__loop__parallel__for();
}