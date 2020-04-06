#include <cassert>
#include <iostream>

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
auto bo = ( counter == 1 ) ;
if ( bo != true) {
    std::cerr << "Expected: " << 1 << " Get: " << counter << std::endl;
    assert(bo);
}

}
int main()
{
    test_target<double>();
}
