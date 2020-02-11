#include <cassert>

void test_target(){

 // Input and Outputs
 

int counter = 0;

// Main program

#pragma omp target   defaultmap(tofrom:scalar) 

{


counter++;

 } 

// Validation
assert( counter  == 1 );

}
int main()
{
    test_target();
}