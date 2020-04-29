#include <iostream>
#include <cstdlib>
#include <cmath>
#include <complex>
using namespace std;
bool almost_equal(complex<float> x, complex<float> gold, float tol) {
        return abs(gold) * (1-tol) <= abs(x) && abs(x) <= abs(gold) * (1 + tol);
}
#pragma omp declare reduction(+: complex<float>: omp_out += omp_in)
void test_target_teams_distribute(){
 const int L = 262144;
 complex<float> counter{};
#pragma omp target teams distribute reduction(+: counter) map(tofrom:counter) 
    for (int i = 0 ; i < L ; i++ )
    {
counter += complex<float> { 1.0f };
    }
if ( !almost_equal(counter,complex<float> { L }, 0.1)  ) {
    std::cerr << "Expected: " << L << " Got: " << counter << std::endl;
    std::exit(112);
}
}
int main()
{
    test_target_teams_distribute();
}
