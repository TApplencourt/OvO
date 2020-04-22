#include <iostream>
#include <cmath>
#include <stdexcept>
bool almost_equal(float x, float gold, float tol) {
        return gold * (1-tol) <= x && x <= gold * ( 1+tol );
}
void test_target__parallel_for(){
 // Input and Outputs
 const int L = 5;
float counter{};
// Main program
#pragma omp target   map(tofrom:counter) 
{
#pragma omp parallel for  reduction(+: counter)  
    for (int i = 0 ; i < L ; i++ )
{
counter += float { 1.0f };
    }
    }
// Validation
if ( !almost_equal(counter,float { L }, 0.1)  ) {
    std::cerr << "Expected: " << L << " Got: " << counter << std::endl;
    throw std::runtime_error( "target__parallel_for give incorect value when offloaded");
}
}
int main()
{
    test_target__parallel_for();
}
