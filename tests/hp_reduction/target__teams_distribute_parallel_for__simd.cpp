#include <cassert>

void test_target__teams_distribute_parallel_for__simd(){

 // Input and Outputs
 
 const int L = 5;
 const int M = 6;

int counter = 0;

// Main program

#pragma omp target   defaultmap(tofrom:scalar) 

{

#pragma omp teams distribute parallel for  reduction(+:counter)  

    for (int i = 0 ; i < L ; i++ )

{

#pragma omp simd  reduction(+:counter)  

    for (int j = 0 ; j < M ; j++ )

{


counter++;

 }  }  } 

// Validation
assert( counter == L*M );

}
int main()
{
    test_target__teams_distribute_parallel_for__simd();
}