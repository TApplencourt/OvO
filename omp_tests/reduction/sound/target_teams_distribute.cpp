#include <stdlib.h>
#include <numeric>
#include <math.h>
#include <cassert>
#include <iostream>
#include <cmath>

void test_target_teams_distribute(){


    // Declare Size of array

    const int L = 10;


    // Initialize array
    int A = 0;

    // Computation
    #pragma omp target teams distribute  reduction(+:A)   defaultmap(tofrom:scalar) 
    for (int i = 0 ; i < L ; i++ )
    {
        A=A+1;
    }

    // Validation
    assert( A == L );

    std::cout << "OK" << std::endl ;
}   

int main()
{
    test_target_teams_distribute();
}
