#include <cassert>

template<class T>
void test_target__teams__parallel(){

 // Input and Outputs
 

T counter{};

// Main program

#pragma omp target  map(tofrom: counter) 

{

#pragma omp teams 

{

#pragma omp parallel 

{


#pragma omp atomic update
counter++;


}

}

}


// Validation
assert( counter  > 0 );

}
int main()
{
    test_target__teams__parallel<double>();
}
