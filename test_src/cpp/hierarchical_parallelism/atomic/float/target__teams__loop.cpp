#include <iostream>
#include <cstdlib>
bool almost_equal(float x, float gold, float tol) {
        return gold * (1-tol) <= x && x <= gold * (1 + tol);
}
void test_target__teams__loop(){
 const int L = 262144;
 float counter{};
#pragma omp target  map(tofrom:counter) 
{
#pragma omp teams 
{
#pragma omp loop 
    for (int i = 0 ; i < L ; i++ )
{
#pragma omp atomic update
counter += float { 1.0f };
    } 
    } 
    } 
if ( !almost_equal(counter,float { L }, 0.1)  ) {
    std::cerr << "Expected: " << L << " Got: " << counter << std::endl;
    std::exit(112);
}
}
int main()
{
    test_target__teams__loop();
}
