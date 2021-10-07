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
void test_modff(){
   const char* usr_precision = getenv("OVO_TOL_ULP");
   const int precision = usr_precision ? atoi(usr_precision) : 4;
   float in0 { 0.42 };
    float out1_host {};
   float out1_device {};
    float out2_host {};
   float out2_device {};
{
    out2_host = modff(in0, &out1_host);
}
  #pragma omp target map(tofrom: out1_device, out2_device)
  {
    out2_device = modff(in0, &out1_device);
  }
           if ( !almost_equal(out1_host,out1_device, precision) ) {
             std::cerr << std::setprecision (std::numeric_limits<float>::max_digits10 ) << "Host: " << out1_host << " GPU: " << out1_device << std::endl;
        std::exit(112);
           }
           if ( !almost_equal(out2_host,out2_device, precision) ) {
             std::cerr << std::setprecision (std::numeric_limits<float>::max_digits10 ) << "Host: " << out2_host << " GPU: " << out2_device << std::endl;
        std::exit(112);
           }
}
int main()
{
    test_modff();
}
