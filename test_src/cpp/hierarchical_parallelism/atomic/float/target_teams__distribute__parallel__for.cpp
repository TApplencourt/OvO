#include <iostream>
#include <limits>
#include <cmath>





bool almost_equal(float x, float y, int ulp) {

     return std::fabs(x-y) <= std::numeric_limits<float>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<float>::min();

}

void test_target_teams__distribute__parallel__for.cpp(){

 // Input and Outputs
 
 const int L = 5;
 const int M = 6;

float counter{};

// Main program

#pragma omp target teams  map(tofrom:counter) 

{


#pragma omp distribute 

    for (int i = 0 ; i < L ; i++ )

{


#pragma omp parallel 

{


#pragma omp for 

    for (int j = 0 ; j < M ; j++ )

{



#pragma omp atomic update

counter += float { 1 };



}

}

}

}


// Validation
if ( !almost_equal(counter,float { L*M }, 10)  ) {
    std::cerr << "Expected: " << L*M << " Got: " << counter << std::endl;
    throw std::runtime_error( "target_teams__distribute__parallel__for.cpp give incorect value when offloaded");
}

}
int main()
{
    test_target_teams__distribute__parallel__for.cpp();
}
