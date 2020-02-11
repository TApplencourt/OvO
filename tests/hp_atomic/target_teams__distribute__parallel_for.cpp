#include <cassert>

template<class T>
void test_target_teams__distribute__parallel_for(){

 // Input and Outputs
 
 const int L = 5;
 const int M = 6;

T counter{};

// Main program

#pragma omp target teams  map(tofrom: counter) 

{

#pragma omp distribute 

    for (int i = 0 ; i < L ; i++ )

{

#pragma omp parallel for 

    for (int j = 0 ; j < M ; j++ )

{


#pragma omp atomic update
counter++;


}

}

}


// Validation
assert( counter == L*M );

}
int main()
{
    test_target_teams__distribute__parallel_for<double>();
}
