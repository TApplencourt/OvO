#include <iostream>
#include <cstdlib>
bool almost_equal(double x, double gold, float tol) {
        return gold * (1-tol) <= x && x <= gold * (1 + tol);
}
void test_target_teams_loop__parallel_loop(){
 const int L = 4096;
 const int M = 64;
 double counter{};
#pragma omp target teams loop map(tofrom:counter) 
    for (int i = 0 ; i < L ; i++ )
    {
double partial_counter{};
#pragma omp parallel loop reduction(+: partial_counter)
    for (int j = 0 ; j < M ; j++ )
    {
partial_counter += double { 1.0f };
    }
#pragma omp atomic update
counter += partial_counter;
    }
if ( !almost_equal(counter,double { L*M }, 0.1)  ) {
    std::cerr << "Expected: " << L*M << " Got: " << counter << std::endl;
    std::exit(112);
}
}
int main()
{
    test_target_teams_loop__parallel_loop();
}
