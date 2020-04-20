#include <iostream>
#include <cmath>
#include <stdexcept>
#ifdef _OPENMP
#include <omp.h>
#else
int omp_get_num_teams() {return 1;}
int omp_get_num_threads() {return 1;}
#endif
bool almost_equal(float x, float gold, float tol) {
    return gold * (1-tol) <= x && x <= gold * ( 1+tol );
}
void test_target_teams__parallel__loop(){
 const int L = 5;
float counter{};
#pragma omp target teams  map(tofrom:counter) 
{
const int num_teams = omp_get_num_teams();
float partial_counter{};
#pragma omp parallel  reduction(+: counter)  
{
#pragma omp loop 
    for (int i = 0 ; i < L ; i++ )
{
partial_counter += float { 1.0f/num_teams } ;
}
}
#pragma omp atomic update
counter += partial_counter;
}
if ( !almost_equal(counter,float { L }, 0.1)  ) {
    std::cerr << "Expected: " << L << " Got: " << counter << std::endl;
    throw std::runtime_error( "target_teams__parallel__loop give incorect value when offloaded");
}
}
int main()
{
    test_target_teams__parallel__loop();
}
