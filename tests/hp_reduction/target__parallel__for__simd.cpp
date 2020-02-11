#include <cassert>

void test_target__parallel__for__simd(){

 // Input and Outputs
 
 const int L = 5;
 const int M = 6;

int counter = 0;

// Main program

#pragma omp target   defaultmap(tofrom:scalar) 

{

#pragma omp parallel  reduction(+:counter)  

{

#pragma omp for  

    for (int i = 0 ; i < L ; i++ )

{

#pragma omp simd  reduction(+:counter)  

    for (int j = 0 ; j < M ; j++ )

{


counter++;

 }  }  }  } 

// Validation
assert( counter == L*M );

}
int main()
{
    test_target__parallel__for__simd();
}