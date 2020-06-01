#include <iostream>
#include <cstdlib>
bool almost_equal(float x, float gold, float tol) {
        return gold * (1-tol) <= x && x <= gold * (1 + tol);
}
void test_target_parallel_loop(){
 const int L = 262144;
 float counter{};
#pragma omp target parallel loop map(tofrom: counter) 
    for (int i = 0 ; i < L ; i++ )
    {
#pragma omp atomic update
counter += float { 1.0f };
    }
if ( !almost_equal(counter,float { L }, 0.1)  ) {
    std::cerr << "Expected: " << L << " Got: " << counter << std::endl;
    std::exit(112);
}
}
int main()
{
    test_target_parallel_loop();
}