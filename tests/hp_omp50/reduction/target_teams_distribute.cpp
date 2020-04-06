#include <cassert>
#include <iostream>
#
void test_target_teams_distribute(){

 // Input and Outputs
 
 const int L = 5;

int counter = 0;

// Main program

#pragma omp target teams distribute  reduction(+:counter)   defaultmap(tofrom:scalar) 

    for (int i = 0 ; i < L ; i++ )

{


counter++;

 } 

// Validation
auto bo = ( counter == L ) ;
if ( bo != true) {
    std::cerr << "Expected: " << L << " Get: " << counter << std::endl;
    assert(bo);
}

}
int main()
{
    test_target_teams_distribute();
}