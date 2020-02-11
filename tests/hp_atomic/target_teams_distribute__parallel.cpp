#include <cassert>
#include <iostream>

template<class T>
void test_target_teams_distribute__parallel(){

 // Input and Outputs
 
 const int L = 5;

T counter{};

// Main program

#pragma omp target teams distribute  map(tofrom: counter) 

    for (int i = 0 ; i < L ; i++ )

{

#pragma omp parallel 

{


#pragma omp atomic update
counter++;


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
    test_target_teams_distribute__parallel<double>();
}
