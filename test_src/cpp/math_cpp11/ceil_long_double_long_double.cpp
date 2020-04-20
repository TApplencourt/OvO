#include <cmath>
#include <limits>
#include <iostream>
#include <stdexcept>
#
using namespace std;
bool almost_equal(long double x, long double y, int ulp) {
     return std::fabs(x-y) <= std::numeric_limits<long double>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<long double>::min();
}
void test_ceil(){
   long double in0 {  0.42 };
   long double out1_host;
   long double out1_device;
    out1_host =  ceil( in0);
   #pragma omp target map(from: out1_device )
   {
     out1_device =  ceil( in0);
   }
   if ( !almost_equal(out1_host,out1_device,1) ) {
        std::cerr << "Host: " << out1_host << " GPU: " << out1_device << std::endl;
        throw std::runtime_error( "ceil give incorect value when offloaded");
    }
}
int main()
{
    test_ceil();
}
