#include <iostream>
#include <stdexcept>

#include <omp.h>


#include <cmath>
#include <limits>



bool almost_equal(double x, double y, int ulp) {

     return std::fabs(x-y) <= std::numeric_limits<double>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<double>::min();

}



void test_target_teams__parallel_for(){

 // Input and Outputs
 
 const int L = 5;

double counter{};

// Main program

#pragma omp target teams  reduction(  +  :counter)   map(tofrom:counter) 

{

const int num_teams = omp_get_num_teams();


#pragma omp parallel for  reduction(  +  :counter)  

    for (int i = 0 ; i < L ; i++ )

{




counter += double { 1./num_teams } ;



}

}


// Validation
if ( !almost_equal(counter,double { L }, 10)  ) {
    std::cerr << "Expected: " << L << " Get: " << counter << std::endl;
    throw std::runtime_error( "target_teams__parallel_for give incorect value when offloaded");
}

}
int main()
{
    test_target_teams__parallel_for();
}
