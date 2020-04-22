#include <iostream>
#include <cmath>
#include <stdexcept>
bool almost_equal(double x, double gold, float tol) {
    return gold * (1-tol) <= x && x <= gold * ( 1+tol );
}
void test_target_teams__distribute__parallel__for__simd(){
 const int L = 5;
 const int M = 6;
 const int N = 7;
double counter{};
#pragma omp target teams  map(tofrom:counter) 
    {
#pragma omp distribute 
    for (int i = 0 ; i < L ; i++ )
    {
double partial_counter{};
#pragma omp parallel  reduction(+: counter)  
    {
#pragma omp for 
    for (int j = 0 ; j < M ; j++ )
    {
#pragma omp simd 
    for (int k = 0 ; k < N ; k++ )
    {
partial_counter += double { 1.0f };
   } 
   } 
   } 
#pragma omp atomic update
counter += partial_counter;
   } 
   } 
if ( !almost_equal(counter,double { L*M*N }, 0.1)  ) {
    std::cerr << "Expected: " << L*M*N << " Got: " << counter << std::endl;
    throw std::runtime_error( "target_teams__distribute__parallel__for__simd give incorect value when offloaded");
}
}
int main()
{
    test_target_teams__distribute__parallel__for__simd();
}
