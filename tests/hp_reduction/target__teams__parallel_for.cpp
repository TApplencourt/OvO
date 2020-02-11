#include <cassert>

void test_target__teams__parallel_for(){

 // Input and Outputs
 
 const int L = 5;

int counter = 0;

// Main program

#pragma omp target   defaultmap(tofrom:scalar) 

{

#pragma omp teams  reduction(+:counter)  

{

#pragma omp parallel for  reduction(+:counter)  

    for (int i = 0 ; i < L ; i++ )

{


counter++;

 }  }  } 

// Validation
assert( counter  > 0 );

}
int main()
{
    test_target__teams__parallel_for();
}