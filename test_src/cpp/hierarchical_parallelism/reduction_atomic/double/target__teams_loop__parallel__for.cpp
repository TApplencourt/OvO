#include <iostream>
#include <cmath>
#include <stdexcept>
bool almost_equal(double x, double gold, float tol) {
    return gold * (1-tol) <= x && x <= gold * ( 1+tol );
}
void test_target__teams_loop__parallel__for(){
 const int L = 5;
 const int M = 6;
double counter{};
#pragma omp target  map(tofrom:counter) 
    {
#pragma omp teams loop 
    for (int i = 0 ; i < L ; i++ )
    {
double partial_counter{};
#pragma omp parallel  reduction(+: counter)  
    {
#pragma omp for 
    for (int j = 0 ; j < M ; j++ )
    {
partial_counter += double { 1.0f };
   } 
   } 
#pragma omp atomic update
counter += partial_counter;
   } 
   } 
if ( !almost_equal(counter,double { L*M }, 0.1)  ) {
    std::cerr << "Expected: " << L*M << " Got: " << counter << std::endl;
    throw std::runtime_error( "target__teams_loop__parallel__for give incorect value when offloaded");
}
}
int main()
{
    test_target__teams_loop__parallel__for();
}
