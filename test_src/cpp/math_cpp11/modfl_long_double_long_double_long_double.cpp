#include <cmath>
#include <limits>
#include <iostream>
#include <stdexcept>
#
using namespace std;
bool almost_equal(long double x, long double y, int ulp) {
     return std::fabs(x-y) <= std::numeric_limits<long double>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<long double>::min();
}
void test_modfl(){
   long double in0 {  0.42 };
   long double out1_host;
   long double out1_device;
   long double out2_host;
   long double out2_device;
    out2_host =  modfl( in0, &out1_host);
   #pragma omp target map(from: out1_device, out2_device )
   {
     out2_device =  modfl( in0, &out1_device);
   }
   if ( !almost_equal(out1_host,out1_device,4) ) {
        std::cerr << "Host: " << out1_host << " GPU: " << out1_device << std::endl;
        throw std::runtime_error( "modfl give incorect value when offloaded");
    }
   if ( !almost_equal(out2_host,out2_device,4) ) {
        std::cerr << "Host: " << out2_host << " GPU: " << out2_device << std::endl;
        throw std::runtime_error( "modfl give incorect value when offloaded");
    }
}
int main()
{
    test_modfl();
}
