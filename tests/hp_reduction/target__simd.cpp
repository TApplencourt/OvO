#include <cassert>

void test_target__simd(){

 // Input and Outputs
 
 const int L = 5;

int counter = 0;

// Main program

#pragma omp target   defaultmap(tofrom:scalar) 

{

#pragma omp simd  reduction(+:counter)  

    for (int i = 0 ; i < L ; i++ )

{


counter++;

 }  } 

// Validation
assert( counter == L );

}
int main()
{
    test_target__simd();
}