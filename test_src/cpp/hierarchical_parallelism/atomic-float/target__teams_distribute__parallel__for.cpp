#include <iostream>
#include <cstdlib>
bool almost_equal(float x, float gold, float tol) {
        return gold * (1-tol) <= x && x <= gold * (1 + tol);
}
void test_target__teams_distribute__parallel__for(){
 const int N0 = 512;
 const int N1 = 512;
 float counter{};
#pragma omp target map(tofrom: counter)
#pragma omp teams distribute
      for (int i0 = 0 ; i0 < N0 ; i0++ )
      {
#pragma omp parallel
#pragma omp for
      for (int i0 = 0 ; i0 < N0 ; i0++ )
      {
#pragma omp atomic update
counter += float { 1.0f };
    }
    }
if ( !almost_equal(counter,float { N0*N1 }, 0.1)  ) {
    std::cerr << "Expected: " << N0*N1 << " Got: " << counter << std::endl;
    std::exit(112);
}
}
int main()
{
    test_target__teams_distribute__parallel__for();
}
