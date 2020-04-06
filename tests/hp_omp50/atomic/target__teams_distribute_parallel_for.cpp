#include <cassert>
#include <iostream>

template<class T>
void test_target__teams_distribute_parallel_for(){

 // Input and Outputs
 
 const int L = 5;

T counter{};

// Main program

#pragma omp target  map(tofrom: counter) 

{

#pragma omp teams distribute parallel for 

    for (int i = 0 ; i < L ; i++ )

{


#pragma omp atomic update
counter++;


}

}


// Validation
auto bo = ( counter == L ) ;
if ( bo != true) {
    std::cerr << "Expected: " << L << " Get: " << counter << std::endl;
    assert(bo);
}

}
int main()
{
    test_target__teams_distribute_parallel_for<double>();
}
