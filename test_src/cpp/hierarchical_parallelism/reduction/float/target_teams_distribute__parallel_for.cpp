#include <iostream>
#include <cmath>
#include <stdexcept>
bool almost_equal(float x, float gold, float tol) {
        return gold * (1-tol) <= x && x <= gold * ( 1+tol );
}
void test_target_teams_distribute__parallel_for(){
 // Input and Outputs
 const int L = 5;
 const int M = 6;
float counter{};
// Main program
#pragma omp target teams distribute  reduction(+: counter)   map(tofrom:counter) 
    for (int i = 0 ; i < L ; i++ )
{
#pragma omp parallel for  reduction(+: counter)  
    for (int j = 0 ; j < M ; j++ )
{
counter += float { 1.0f };
    }
    }
// Validation
if ( !almost_equal(counter,float { L*M }, 0.1)  ) {
    std::cerr << "Expected: " << L*M << " Got: " << counter << std::endl;
    throw std::runtime_error( "target_teams_distribute__parallel_for give incorect value when offloaded");
}
}
int main()
{
    test_target_teams_distribute__parallel_for();
}
