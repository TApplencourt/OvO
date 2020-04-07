#include <iostream>
#include <stdexcept>

#include <omp.h>




#include <cmath>
#include <limits>



bool almost_equal(double x, double y, int ulp) {

     return std::fabs(x-y) <= std::numeric_limits<double>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<double>::min();

}

void test_target_teams__distribute__parallel(){

 // Input and Outputs
 
 const int L = 5;

double counter{};

// Main program

#pragma omp target teams  map(tofrom:counter) 

{


#pragma omp distribute 

    for (int i = 0 ; i < L ; i++ )

{


#pragma omp parallel 

{

const int num_threads = omp_get_num_threads();



#pragma omp atomic update

counter += double { 1./num_threads };



}

}

}


// Validation
if ( !almost_equal(counter,double { L }, 1)  ) {
    std::cerr << "Expected: " << L << " Get: " << counter << std::endl;
    throw std::runtime_error( "target_teams__distribute__parallel give incorect value when offloaded");
}

}
int main()
{
    test_target_teams__distribute__parallel();
}
