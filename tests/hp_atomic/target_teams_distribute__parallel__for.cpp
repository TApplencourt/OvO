#include <cassert>

template<class T>
void test_target_teams_distribute__parallel__for(){

 // Input and Outputs
 
 const int L = 5;
 const int M = 6;

T counter{};

// Main program

#pragma omp target teams distribute  map(tofrom: counter) 

    for (int i = 0 ; i < L ; i++ )

{

#pragma omp parallel 

{

#pragma omp for 

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
    test_target_teams_distribute__parallel__for<double>();
}
