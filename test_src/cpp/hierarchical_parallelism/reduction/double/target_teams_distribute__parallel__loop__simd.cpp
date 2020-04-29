#include <iostream>
#include <cstdlib>
bool almost_equal(double x, double gold, float tol) {
        return gold * (1-tol) <= x && x <= gold * (1 + tol);
}
void test_target_teams_distribute__parallel__loop__simd(){
 const int L = 64;
 const int M = 64;
 const int N = 64;
 double counter{};
#pragma omp target teams distribute reduction(+: counter) map(tofrom:counter) 
    for (int i = 0 ; i < L ; i++ )
    {
#pragma omp parallel reduction(+: counter)
#pragma omp loop
    for (int j = 0 ; j < M ; j++ )
    {
#pragma omp simd reduction(+: counter)
    for (int k = 0 ; k < N ; k++ )
    {
counter += double { 1.0f };
    }
    }
    }
if ( !almost_equal(counter,double { L*M*N }, 0.1)  ) {
    std::cerr << "Expected: " << L*M*N << " Got: " << counter << std::endl;
    std::exit(112);
}
}
int main()
{
    test_target_teams_distribute__parallel__loop__simd();
}
