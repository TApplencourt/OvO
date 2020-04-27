#include <cmath>
#include <limits>
#include <iostream>
#include <stdexcept>
#
using namespace std;
bool almost_equal(long double x, long double y, int ulp) {
     return std::fabs(x-y) <= std::numeric_limits<long double>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<long double>::min();
}
void test_powl(){
   long double x {  0.42 };
   long double y {  0.42 };
   long double o_host;
   long double o_device;
    o_host =  powl( x, y);
   #pragma omp target map(from: o_device )
   {
     o_device =  powl( x, y);
   }
   if ( !almost_equal(o_host,o_device, 4) ) {
        std::cerr << "Host: " << o_host << " GPU: " << o_device << std::endl;
        throw std::runtime_error( "powl give incorect value when offloaded");
    }
}
int main()
{
    test_powl();
}
