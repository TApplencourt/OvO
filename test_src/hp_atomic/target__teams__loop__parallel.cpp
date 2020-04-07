#include <cassert>
#include <iostream>

template<class T>
void test_target__teams__loop__parallel(){

 // Input and Outputs
 
 const int L = 5;

T counter{};

// Main program

#pragma omp target  map(tofrom: counter) 

{

#pragma omp teams 

{

#pragma omp loop 

    for (int i = 0 ; i < L ; i++ )

{

#pragma omp parallel 

{


#pragma omp atomic update
counter++;


}

}

}

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
    test_target__teams__loop__parallel<double>();
}
