#include <iostream>
#include <cmath>
#include <stdexcept>

#include <complex>
using namespace std;




bool almost_equal(complex<double> x, complex<double> gold, float tol) {
    
        return abs(gold) * (1-tol) <= abs(x) && abs(x) <= abs(gold) * (1 + tol ); 
    
}


#pragma omp declare reduction(+: complex<double>:   omp_out += omp_in) 


void test_target_teams_loop__parallel__for(){

 // Input and Outputs
 
 const int L = 5;
 const int M = 6;

complex<double> counter{};

// Main program

#pragma omp target teams loop  reduction(+: counter)   map(tofrom:counter) 

    for (int i = 0 ; i < L ; i++ )

{


#pragma omp parallel  reduction(+: counter)  

{


#pragma omp for  

    for (int j = 0 ; j < M ; j++ )

{




counter += complex<double> { 1.0f };



}

}

}


// Validation
if ( !almost_equal(counter,complex<double> { L*M }, 0.1)  ) {
    std::cerr << "Expected: " << L*M << " Got: " << counter << std::endl;
    throw std::runtime_error( "target_teams_loop__parallel__for give incorect value when offloaded");
}

}
int main()
{
    test_target_teams_loop__parallel__for();
}
