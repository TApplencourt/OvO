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
void test_copysignf(){
   const char* usr_precision = getenv("OVO_TOL_ULP");
   const int precision = usr_precision ? atoi(usr_precision) : 4;
   float in0 { 0.42 };
   float in1 { 0.42 };
    float out2_host {};
   float out2_device {};
   {
    out2_host = copysignf(in0, in1);
   }
   #pragma omp target map(tofrom: out2_device )
   {
    out2_device = copysignf(in0, in1);
   }
   if ( !almost_equal(out2_host,out2_device, precision) ) {
        std::cerr << std::setprecision (std::numeric_limits<float>::max_digits10 ) << "Host: " << out2_host << " GPU: " << out2_device << std::endl;
        std::exit(112);
    }
}
int main()
{
    test_copysignf();
}
