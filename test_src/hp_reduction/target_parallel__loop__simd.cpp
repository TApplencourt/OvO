#include <cassert>
#include <iostream>
#
void test_target_parallel__loop__simd(){

 // Input and Outputs
 
 const int L = 5;
 const int M = 6;

int counter = 0;

// Main program

#pragma omp target parallel  reduction(+:counter)   defaultmap(tofrom:scalar) 

{

#pragma omp loop  reduction(+:counter)  

    for (int i = 0 ; i < L ; i++ )

{

#pragma omp simd  reduction(+:counter)  

    for (int j = 0 ; j < M ; j++ )

{


counter++;

 }  }  } 

// Validation
auto bo = ( counter == L*M ) ;
if ( bo != true) {
    std::cerr << "Expected: " << L*M << " Get: " << counter << std::endl;
    assert(bo);
}

}
int main()
{
    test_target_parallel__loop__simd();
}