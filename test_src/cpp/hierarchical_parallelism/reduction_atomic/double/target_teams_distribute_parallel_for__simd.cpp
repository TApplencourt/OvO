#include <iostream>
#include <cmath>
#include <stdexcept>
bool almost_equal(double x, double gold, float tol) {
    return gold * (1-tol) <= x && x <= gold * ( 1+tol );
}
void test_target_teams_distribute_parallel_for__simd(){
 const int L = 5;
 const int M = 6;
double counter{};
double partial_counter{};
#pragma omp target teams distribute parallel for  reduction(+: counter)   map(tofrom:partial_counter) 
    for (int i = 0 ; i < L ; i++ )
    {
#pragma omp simd 
    for (int j = 0 ; j < M ; j++ )
    {
partial_counter += double { 1.0f };
   } 
   } 
#pragma omp atomic update
counter += partial_counter;
if ( !almost_equal(counter,double { L*M }, 0.1)  ) {
    std::cerr << "Expected: " << L*M << " Got: " << counter << std::endl;
    throw std::runtime_error( "target_teams_distribute_parallel_for__simd give incorect value when offloaded");
}
}
int main()
{
    test_target_teams_distribute_parallel_for__simd();
}