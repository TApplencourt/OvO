#include <iostream>
#include <cstdlib>
bool almost_equal(float x, float gold, float tol) {
        return gold * (1-tol) <= x && x <= gold * (1 + tol);
}
void test_target__simd(){
 const int N_i = 64;
 float counter{};
#pragma omp target map(tofrom: counter) 
#pragma omp simd reduction(+: counter)
    for (int i = 0 ; i < N_i ; i++ )
    {
counter += float { 1.0f };
    }
if ( !almost_equal(counter,float { N_i }, 0.1)  ) {
    std::cerr << "Expected: " << N_i << " Got: " << counter << std::endl;
    std::exit(112);
}
}
int main()
{
    test_target__simd();
}
