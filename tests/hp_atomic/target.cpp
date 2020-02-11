#include <cassert>

template<class T>
void test_target(){

 // Input and Outputs
 

T counter{};

// Main program

#pragma omp target  map(tofrom: counter) 

{


#pragma omp atomic update
counter++;


}


// Validation
assert( counter  == 1 );

}
int main()
{
    test_target<double>();
}
