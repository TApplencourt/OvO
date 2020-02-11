#include <cassert>

void test_target__teams(){

 // Input and Outputs
 

int counter = 0;

// Main program

#pragma omp target   defaultmap(tofrom:scalar) 

{

#pragma omp teams  reduction(+:counter)  

{


counter++;

 }  } 

// Validation
assert( counter  > 0 );

}
int main()
{
    test_target__teams();
}