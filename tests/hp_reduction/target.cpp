#include <cassert>
#include <iostream>
#
void test_target(){

 // Input and Outputs
 

int counter = 0;

// Main program

#pragma omp target   defaultmap(tofrom:scalar) 

{


counter++;

 } 

// Validation
auto bo = ( counter == 1 ) ;
if ( bo != true) {
    std::cerr << "Expected: " << 1 << " Get: " << counter << std::endl;
    assert(bo);
}

}
int main()
{
    test_target();
}