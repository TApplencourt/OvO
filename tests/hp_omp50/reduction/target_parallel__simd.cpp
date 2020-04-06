#include <cassert>
#include <iostream>
#
void test_target_parallel__simd(){

 // Input and Outputs
 
 const int L = 5;

int counter = 0;

// Main program

#pragma omp target parallel  reduction(+:counter)   defaultmap(tofrom:scalar) 

{

#pragma omp simd  reduction(+:counter)  

    for (int i = 0 ; i < L ; i++ )

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
    test_target_parallel__simd();
}