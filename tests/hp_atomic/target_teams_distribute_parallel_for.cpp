#include <cassert>

template<class T>
void test_target_teams_distribute_parallel_for(){

 // Input and Outputs
 
 const int L = 5;

T counter{};

// Main program

#pragma omp target teams distribute parallel for  map(tofrom: counter) 

    for (int i = 0 ; i < L ; i++ )

{


#pragma omp atomic update
counter++;


}


// Validation
assert( counter == L );

}
int main()
{
    test_target_teams_distribute_parallel_for<double>();
}
