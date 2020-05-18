#include <iostream>
#include <cstdlib>
bool almost_equal(double x, double gold, float tol) {
        return gold * (1-tol) <= x && x <= gold * (1 + tol);
}
void test_target__teams_distribute_simd(){
 const int L = 262144;
 double counter{};
#pragma omp target map(tofrom: counter) 
#pragma omp teams distribute simd reduction(+: counter)
    for (int i = 0 ; i < L ; i++ )
    {
counter += double { 1.0f };
    }
if ( !almost_equal(counter,double { L }, 0.1)  ) {
    std::cerr << "Expected: " << L << " Got: " << counter << std::endl;
    std::exit(112);
}
}
int main()
{
    test_target__teams_distribute_simd();
}
