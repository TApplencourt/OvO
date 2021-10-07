#include <cmath>
#include <iomanip>
#include <stdlib.h>
#include <limits>
#include <iostream>
#include <cstdlib>
using namespace std;
bool almost_equal(float x, float y, int ulp) {
     return std::fabs(x-y) <= std::numeric_limits<float>::epsilon() * std::fabs(x+y) * ulp || std::fabs(x-y) < std::numeric_limits<float>::min();
}
void test_atan2(){
   const char* usr_precision = getenv("OVO_TOL_ULP");
   const int precision = usr_precision ? atoi(usr_precision) : 4;
   float y { 0.42 };
   float x { 0.42 };
    float o_host {};
   float o_device {};
   {
    o_host = atan2(y, x);
   }
   #pragma omp target map(tofrom: o_device )
   #pragma omp simd
   {
    o_device = atan2(y, x);
   }
   if ( !almost_equal(o_host,o_device, precision) ) {
        std::cerr << std::setprecision (std::numeric_limits<float>::max_digits10 ) << "Host: " << o_host << " GPU: " << o_device << std::endl;
        std::exit(112);
    }
}
int main()
{
    test_atan2();
}
