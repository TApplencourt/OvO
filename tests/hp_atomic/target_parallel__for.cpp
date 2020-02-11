#include <cassert>

template<class T>
void test_target_parallel__for(){

 // Input and Outputs
 
 const int L = 5;

T counter{};

// Main program

#pragma omp target parallel  map(tofrom: counter) 

{

#pragma omp for 

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
    test_target_parallel__for<double>();
}
