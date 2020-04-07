#include <cassert>
#include <iostream>
#
void test_target_teams_loop__parallel(){

 // Input and Outputs
 
 const int L = 5;

int counter = 0;

// Main program

#pragma omp target teams loop  reduction(+:counter)   defaultmap(tofrom:scalar) 

    for (int i = 0 ; i < L ; i++ )

{

#pragma omp parallel  reduction(+:counter)  

{


counter++;

 }  } 

// Validation
auto bo = ( counter > 0 ) ;
if ( bo != true) {
    std::cerr << "Expected: " << 0 << " Get: " << counter << std::endl;
    assert(bo);
}

}
int main()
{
    test_target_teams_loop__parallel();
}