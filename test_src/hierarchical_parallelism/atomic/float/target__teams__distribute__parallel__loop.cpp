#include <iostream>
#include <stdexcept>




#include <cmath>
#include <limits>



bool almost_equal(float x, float y, int ulp) {

     return std::fabs(x-y) <= std::numeric_limits<float>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<float>::min();

}

void test_target__teams__distribute__parallel__loop(){

 // Input and Outputs
 
 const int L = 5;
 const int M = 6;

float counter{};

// Main program

#pragma omp target  map(tofrom:counter) 

{


#pragma omp teams 

{


#pragma omp distribute 

    for (int i = 0 ; i < L ; i++ )

{


#pragma omp parallel 

{


#pragma omp loop 

    for (int j = 0 ; j < M ; j++ )

{



#pragma omp atomic update

counter += float { 1 };



}

}

}

}

}


// Validation
if ( !almost_equal(counter,float { L*M }, 10)  ) {
    std::cerr << "Expected: " << L*M << " Get: " << counter << std::endl;
    throw std::runtime_error( "target__teams__distribute__parallel__loop give incorect value when offloaded");
}

}
int main()
{
    test_target__teams__distribute__parallel__loop();
}
