#include <iostream>
#include <cmath>
#include <stdexcept>
bool almost_equal(float x, float gold, float tol) {
    return gold * (1-tol) <= x && x <= gold * ( 1+tol );
}
void test_target__teams__loop__parallel__loop__simd(){
 const int L = 5;
 const int M = 6;
 const int N = 7;
float counter{};
#pragma omp target  map(tofrom:counter) 
    {
#pragma omp teams 
    {
#pragma omp loop 
    for (int i = 0 ; i < L ; i++ )
    {
float partial_counter{};
#pragma omp parallel  reduction(+: counter)  
    {
#pragma omp loop 
    for (int j = 0 ; j < M ; j++ )
    {
#pragma omp simd 
    for (int k = 0 ; k < N ; k++ )
    {
partial_counter += float { 1.0f };
   } 
   } 
   } 
#pragma omp atomic update
counter += partial_counter;
   } 
   } 
   } 
if ( !almost_equal(counter,float { L*M*N }, 0.1)  ) {
    std::cerr << "Expected: " << L*M*N << " Got: " << counter << std::endl;
    throw std::runtime_error( "target__teams__loop__parallel__loop__simd give incorect value when offloaded");
}
}
int main()
{
    test_target__teams__loop__parallel__loop__simd();
}