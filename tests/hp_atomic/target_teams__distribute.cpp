#include <cassert>

template<class T>
void test_target_teams__distribute(){

 // Input and Outputs
 
 const int L = 5;

T counter{};

// Main program

#pragma omp target teams  map(tofrom: counter) 

{

#pragma omp distribute 

    for (int i = 0 ; i < L ; i++ )

{


#pragma omp atomic update
counter++;


}

}


// Validation
assert( counter == L );

}
int main()
{
    test_target_teams__distribute<double>();
}
