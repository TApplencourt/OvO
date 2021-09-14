#include <complex>
#include <cmath>
#include <iomanip>
#include <limits>
#include <iostream>
#include <cstdlib>
using namespace std;
bool almost_equal(complex<float> x, complex<float> y, int ulp) {
    return std::abs(x-y) <= std::numeric_limits<float>::epsilon() * std::abs(x+y) * ulp ||  std::abs(x-y) < std::numeric_limits<float>::min();
}
void test_asin(){
   complex<float> x { 0.42, 0.0 };
   complex<float> o_device {};
   #pragma omp target map(tofrom: o_device )
   {
    o_device =  asin(x);
   }
   if ( !almost_equal(sin(o_device), x, 16) ) {
            std::cerr << std::setprecision (std::numeric_limits<float>::max_digits10 ) << "Expected:" << x << " Got: "  << sin(o_device) << std::endl;
            std::exit(112);
   }
}
int main()
{
    test_asin();
}
