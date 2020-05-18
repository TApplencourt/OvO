#include <iostream>
#include <cstdlib>
#include <cmath>
#include <complex>
using namespace std;
#ifdef _OPENMP
#include <omp.h>
#else
int omp_get_num_teams()   {return 1;}
int omp_get_num_threads() {return 1;}
#endif
bool almost_equal(complex<float> x, complex<float> gold, float tol) {
        return abs(gold) * (1-tol) <= abs(x) && abs(x) <= abs(gold) * (1 + tol);
}
#pragma omp declare reduction(+: complex<float>: omp_out += omp_in)
void test_target__parallel(){
 complex<float> counter{};
#pragma omp target map(tofrom: counter) 
#pragma omp parallel reduction(+: counter)
    {
const int num_threads = omp_get_num_threads();
counter += complex<float> { 1.0f/num_threads };
    }
if ( !almost_equal(counter,complex<float> { 1 }, 0.1)  ) {
    std::cerr << "Expected: " << 1 << " Got: " << counter << std::endl;
    std::exit(112);
}
}
int main()
{
    test_target__parallel();
}
