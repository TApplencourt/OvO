#include <iostream>
#include <cstdlib>
bool almost_equal(float x, float gold, float tol) {
        return gold * (1-tol) <= x && x <= gold * (1 + tol);
}
void test_target_teams_distribute__parallel__for__simd(){
 const int N0 = 64;
 const int N1 = 64;
 const int N2 = 64;
 float counter{};
#pragma omp target teams distribute reduction(+: counter) map(tofrom: counter)
      for (int i0 = 0 ; i0 < N0 ; i0++ )
      {
#pragma omp parallel reduction(+: counter)
#pragma omp for
      for (int i0 = 0 ; i0 < N0 ; i0++ )
      {
#pragma omp simd reduction(+: counter)
      for (int i0 = 0 ; i0 < N0 ; i0++ )
      {
counter += float { 1.0f };
    }
    }
    }
if ( !almost_equal(counter,float { N0*N1*N2 }, 0.1)  ) {
    std::cerr << "Expected: " << N0*N1*N2 << " Got: " << counter << std::endl;
    std::exit(112);
}
}
int main()
{
    test_target_teams_distribute__parallel__for__simd();
}
