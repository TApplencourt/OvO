#include <cassert>
#include <iostream>

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
auto bo = ( counter > 0 ) ;
if ( bo != true) {
    std::cerr << "Expected: " << 0 << " Get: " << counter << std::endl;
    assert(bo);
}

}
int main()
{
    test_target_teams<double>();
}
