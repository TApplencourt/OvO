#include <cassert>

void test_target_teams__parallel(){

 // Input and Outputs
 

int counter = 0;

// Main program

#pragma omp target teams  reduction(+:counter)   defaultmap(tofrom:scalar) 

{

#pragma omp parallel  reduction(+:counter)  

{


counter++;

 }  } 

// Validation
assert( counter  > 0 );

}
int main()
{
    test_target_teams__parallel();
}