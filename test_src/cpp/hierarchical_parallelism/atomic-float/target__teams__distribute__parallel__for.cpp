#include <iostream>
#include <cstdlib>
bool almost_equal(float x, float gold, float tol) {
        return gold * (1-tol) <= x && x <= gold * (1 + tol);
}
void test_target__teams__distribute__parallel__for(){
 const int N_i = 64;
 const int N_j = 64;
 float counter{};
#pragma omp target map(tofrom: counter) 
#pragma omp teams
#pragma omp distribute
    for (int i = 0 ; i < N_i ; i++ )
    {
#pragma omp parallel
#pragma omp for
    for (int j = 0 ; j < N_j ; j++ )
    {
#pragma omp atomic update
counter += float { 1.0f };
    }
    }
if ( !almost_equal(counter,float { N_i*N_j }, 0.1)  ) {
    std::cerr << "Expected: " << N_i*N_j << " Got: " << counter << std::endl;
    std::exit(112);
}
}
int main()
{
    test_target__teams__distribute__parallel__for();
}
