#include <iostream>
#include <cstdlib>
bool almost_equal(float x, float gold, float tol) {
        return gold * (1-tol) <= x && x <= gold * (1 + tol);
}
void test_target__teams_distribute__parallel_for__simd(){
 const int N_i = 64;
 const int N_j = 64;
 const int N_k = 64;
 float counter{};
#pragma omp target map(tofrom: counter) 
#pragma omp teams distribute reduction(+: counter)
    for (int i = 0 ; i < N_i ; i++ )
    {
#pragma omp parallel for reduction(+: counter)
    for (int j = 0 ; j < N_j ; j++ )
    {
#pragma omp simd reduction(+: counter)
    for (int k = 0 ; k < N_k ; k++ )
    {
counter += float { 1.0f };
    }
    }
    }
if ( !almost_equal(counter,float { N_i*N_j*N_k }, 0.1)  ) {
    std::cerr << "Expected: " << N_i*N_j*N_k << " Got: " << counter << std::endl;
    std::exit(112);
}
}
int main()
{
    test_target__teams_distribute__parallel_for__simd();
}
