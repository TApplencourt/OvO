#include <iostream>
#include <cmath>
#include <stdexcept>
#ifdef _OPENMP
#include <omp.h>
#else
int omp_get_num_teams() {return 1;}
int omp_get_num_threads() {return 1;}
#endif
bool almost_equal(double x, double gold, float tol) {
        return gold * (1-tol) <= x && x <= gold * ( 1+tol );
}
void test_target_teams__parallel(){
 // Input and Outputs
double counter{};
// Main program
#pragma omp target teams  map(tofrom:counter) 
{
const int num_teams = omp_get_num_teams();
 double partial_counter{};
#pragma omp parallel  reduction(+: counter)  
{
const int num_threads = omp_get_num_threads();
partial_counter += double { 1.0f/(num_teams*num_threads) } ;
}
#pragma omp atomic update
counter += partial_counter;
}
// Validation
if ( !almost_equal(counter,double { 1 }, 0.1)  ) {
    std::cerr << "Expected: " << 1 << " Got: " << counter << std::endl;
    throw std::runtime_error( "target_teams__parallel give incorect value when offloaded");
}
}
int main()
{
    test_target_teams__parallel();
}
