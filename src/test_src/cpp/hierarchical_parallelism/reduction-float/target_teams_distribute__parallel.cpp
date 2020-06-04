#include <iostream>
#include <cstdlib>
#ifdef _OPENMP
#include <omp.h>
#else
int omp_get_num_teams()   {return 1;}
int omp_get_num_threads() {return 1;}
#endif
bool almost_equal(float x, float gold, float tol) {
        return gold * (1-tol) <= x && x <= gold * (1 + tol);
}
void test_target_teams_distribute__parallel(){
 const int N_i = 64;
 float counter{};
#pragma omp target teams distribute reduction(+: counter) map(tofrom: counter) 
    for (int i = 0 ; i < N_i ; i++ )
    {
#pragma omp parallel reduction(+: counter)
    {
const int num_threads = omp_get_num_threads();
counter += float { 1.0f/num_threads };
    }
    }
if ( !almost_equal(counter,float { N_i }, 0.1)  ) {
    std::cerr << "Expected: " << N_i << " Got: " << counter << std::endl;
    std::exit(112);
}
}
int main()
{
    test_target_teams_distribute__parallel();
}
