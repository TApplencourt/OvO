#include <cassert>
#include <iostream>

template<class T>
void test_target__teams_distribute__parallel_loop(){

 // Input and Outputs
 
 const int L = 5;
 const int M = 6;

T counter{};

// Main program

#pragma omp target  map(tofrom: counter) 

{

#pragma omp teams distribute 

    for (int i = 0 ; i < L ; i++ )

{

#pragma omp parallel loop 

    for (int j = 0 ; j < M ; j++ )

{


#pragma omp atomic update
counter++;


}

}

}


// Validation
auto bo = ( counter == L*M ) ;
if ( bo != true) {
    std::cerr << "Expected: " << L*M << " Get: " << counter << std::endl;
    assert(bo);
}

}
int main()
{
    test_target__teams_distribute__parallel_loop<double>();
}
