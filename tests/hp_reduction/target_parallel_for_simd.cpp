#include <cassert>

void test_target_parallel_for_simd(){

 // Input and Outputs
 
 const int L = 5;

int counter = 0;

// Main program

#pragma omp target parallel for simd  reduction(+:counter)   defaultmap(tofrom:scalar) 

    for (int i = 0 ; i < L ; i++ )

{


counter++;

 } 

// Validation
assert( counter == L );

}
int main()
{
    test_target_parallel_for_simd();
}