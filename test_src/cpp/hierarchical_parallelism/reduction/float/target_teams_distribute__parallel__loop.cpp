#include <iostream>
#include <limits>
#include <cmath>
#include <stdexcept>




bool almost_equal(float x, float y, int ulp) {

     return std::fabs(x-y) <= std::numeric_limits<float>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<float>::min();

}



void test_target_teams_distribute__parallel__loop(){

 // Input and Outputs
 
 const int L = 5;
 const int M = 6;

float counter{};

// Main program

#pragma omp target teams distribute  reduction(+: counter)   map(tofrom:counter) 

    for (int i = 0 ; i < L ; i++ )

{


#pragma omp parallel  reduction(+: counter)  

{


#pragma omp loop  reduction(+: counter)  

    for (int j = 0 ; j < M ; j++ )

{




counter += float { 1.0f };



}

}

}


// Validation
if ( !almost_equal(counter,float { L*M }, 10)  ) {
    std::cerr << "Expected: " << L*M << " Got: " << counter << std::endl;
    throw std::runtime_error( "target_teams_distribute__parallel__loop give incorect value when offloaded");
}

}
int main()
{
    test_target_teams_distribute__parallel__loop();
}
