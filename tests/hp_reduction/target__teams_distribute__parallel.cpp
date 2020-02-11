#include <cassert>

void test_target__teams_distribute__parallel(){

 // Input and Outputs
 
 const int L = 5;

int counter = 0;

// Main program

#pragma omp target   defaultmap(tofrom:scalar) 

{

#pragma omp teams distribute  reduction(+:counter)  

    for (int i = 0 ; i < L ; i++ )

{

#pragma omp parallel  reduction(+:counter)  

{


counter++;

 }  }  } 

// Validation
assert( counter  > 0 );

}
int main()
{
    test_target__teams_distribute__parallel();
}