#include <cassert>

template<class T>
void test_target_teams(){

 // Input and Outputs
 

T counter{};

// Main program

#pragma omp target teams  map(tofrom: counter) 

{


#pragma omp atomic update
counter++;


}


// Validation
assert( counter  > 0 );

}
int main()
{
    test_target_teams<double>();
}
