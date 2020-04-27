#include <iostream>
#include <cstdlib>
bool almost_equal(double x, double gold, float tol) {
        return gold * (1-tol) <= x && x <= gold * (1 + tol);
}
void test_target(){
 double counter{};
#pragma omp target   map(tofrom:counter) 
{
counter += double { 1.0f };
    }
if ( !almost_equal(counter,double { 1 }, 0.1)  ) {
    std::cerr << "Expected: " << 1 << " Got: " << counter << std::endl;
    std::exit(112);
}
}
int main()
{
    test_target();
}
