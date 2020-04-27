#include <iostream>
#include <cstdlib>
#include <cmath>
#include <complex>
using namespace std;
bool almost_equal(complex<float> x, complex<float> gold, float tol) {
        return abs(gold) * (1-tol) <= abs(x) && abs(x) <= abs(gold) * (1 + tol);
}
#pragma omp declare reduction(+: complex<float>:   omp_out += omp_in)
void test_target(){
 complex<float> counter{};
#pragma omp target   map(tofrom:counter) 
{
counter += complex<float> { 1.0f };
    }
if ( !almost_equal(counter,complex<float> { 1 }, 0.1)  ) {
    std::cerr << "Expected: " << 1 << " Got: " << counter << std::endl;
    std::exit(112);
}
}
int main()
{
    test_target();
}
