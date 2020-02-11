#include <cassert>

void test_target__parallel_for_simd(){

 // Input and Outputs
 
 const int L = 5;

int counter = 0;

// Main program

#pragma omp target   defaultmap(tofrom:scalar) 

{

#pragma omp parallel for simd  reduction(+:counter)  

    for (int i = 0 ; i < L ; i++ )

{


counter++;

 }  } 

// Validation
assert( counter == L );

}
int main()
{
    test_target__parallel_for_simd();
}