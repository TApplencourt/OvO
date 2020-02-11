#include <cassert>

template<class T>
void test_target__parallel__for(){

 // Input and Outputs
 
 const int L = 5;

T counter{};

// Main program

#pragma omp target  map(tofrom: counter) 

{

#pragma omp parallel 

{

#pragma omp for 

    for (int i = 0 ; i < L ; i++ )

{


#pragma omp atomic update
counter++;


}

}

}


// Validation
assert( counter == L );

}
int main()
{
    test_target__parallel__for<double>();
}
