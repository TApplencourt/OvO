#include <cassert>

void test_target_teams_distribute__parallel_for(){

 // Input and Outputs
 
 const int L = 5;
 const int M = 6;

int counter = 0;

// Main program

#pragma omp target teams distribute  reduction(+:counter)   defaultmap(tofrom:scalar) 

    for (int i = 0 ; i < L ; i++ )

{

#pragma omp parallel for  reduction(+:counter)  

    for (int j = 0 ; j < M ; j++ )

{


counter++;

 }  } 

// Validation
assert( counter == L*M );

}
int main()
{
    test_target_teams_distribute__parallel_for();
}