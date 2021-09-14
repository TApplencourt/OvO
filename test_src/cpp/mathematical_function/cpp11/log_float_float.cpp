#include <cmath>
#include <iomanip>
#include <limits>
#include <iostream>
#include <cstdlib>
using namespace std;
bool almost_equal(float x, float y, int ulp) {
     return std::fabs(x-y) <= std::numeric_limits<float>::epsilon() * std::fabs(x+y) * ulp || std::fabs(x-y) < std::numeric_limits<float>::min();
}
void test_log(){
   float x { 0.42 };
   float o_device {};
   #pragma omp target map(tofrom: o_device )
   {
    o_device = log(x);
   }
   if ( !almost_equal(exp(o_device), x, 16) ) {
            std::cerr << std::setprecision (std::numeric_limits<float>::max_digits10 ) << "Expected:" << x << " Got: " << exp(o_device) << std::endl;
            std::exit(112);
   }
}
int main()
{
    test_log();
}
