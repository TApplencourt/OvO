#include <iostream>
#include <cmath>
#include <stdexcept>
#include <complex>
using namespace std;
bool almost_equal(complex<double> x, complex<double> gold, float tol) {
        return abs(gold) * (1-tol) <= abs(x) && abs(x) <= abs(gold) * (1 + tol ); 
}
#pragma omp declare reduction(+: complex<double>:   omp_out += omp_in) 
void test_target(){
 // Input and Outputs
complex<double> counter{};
// Main program
#pragma omp target   map(tofrom:counter) 
{
counter += complex<double> { 1.0f };
    }
// Validation
if ( !almost_equal(counter,complex<double> { 1 }, 0.1)  ) {
    std::cerr << "Expected: " << 1 << " Got: " << counter << std::endl;
    throw std::runtime_error( "target give incorect value when offloaded");
}
}
int main()
{
    test_target();
}
