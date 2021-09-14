#include <complex>
#include <cmath>
#include <iomanip>
#include <limits>
#include <iostream>
#include <cstdlib>
using namespace std;
bool almost_equal(complex<float> x, complex<float> y, int ulp) {
    return std::abs(x-y) <= std::numeric_limits<float>::epsilon() * std::abs(x+y) * ulp || std::abs(x-y) < std::numeric_limits<float>::min();
}
void test_acos(){
   complex<float> x { 4.42, 0.0 };
   complex<float> o_device {};
   #pragma omp target map(tofrom: o_device )
   {
    o_device = acos(x);
   }
   if ( !almost_equal(cos(o_device), x, 16) ) {
            std::cerr << std::setprecision (std::numeric_limits<float>::max_digits10 ) << "Expected:" << x << " Got: " << cos(o_device) << std::endl;
            std::exit(112);
   }
}
int main()
{
    test_acos();
}
