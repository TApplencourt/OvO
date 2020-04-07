#include <iostream>
#include <stdexcept>
#include <omp.h>

#include <cmath>
#include <limits>
template<class T>
bool almost_equal(T x, T y, int ulp) {
    return std::fabs(x-y) <= std::numeric_limits<T>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<T>::min();
}

template<class T>
void test_target_teams(){

 // Input and Outputs
 

T counter{};

// Main program

#pragma omp target teams  map(tofrom: counter) 

{

const int num_teams = omp_get_num_teams();



#pragma omp atomic update

counter = counter + 1./num_teams;



}


// Validation
if ( !almost_equal(counter,T{ 1 }, 1)  ) {
    std::cerr << "Expected: " << 1 << " Get: " << counter << std::endl;
    throw std::runtime_error( "target_teams give incorect value when offloaded");
}

}
int main()
{
    test_target_teams<double>();
}
