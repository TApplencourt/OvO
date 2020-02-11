#include <cassert>

template<class T>
void test_target_parallel(){

 // Input and Outputs
 

T counter{};

// Main program

#pragma omp target parallel  map(tofrom: counter) 

{


#pragma omp atomic update
counter++;


}


// Validation
assert( counter  > 0 );

}
int main()
{
    test_target_parallel<double>();
}
