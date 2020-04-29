#include <cmath>
#include <limits>
#include <iostream>
#include <cstdlib>
using namespace std;
bool almost_equal(long double x, long double y, int ulp) {
     return std::fabs(x-y) <= std::numeric_limits<long double>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<long double>::min();
}
void test_scalblnl(){
   long double in0 {  0.42 };
   long int in1 {  1 };
   long double out2_host;
   long double out2_device;
    out2_host =  scalblnl( in0, in1);
   #pragma omp target map(from: out2_device )
   {
     out2_device =  scalblnl( in0, in1);
   }
   if ( !almost_equal(out2_host,out2_device, 4) ) {
        std::cerr << "Host: " << out2_host << " GPU: " << out2_device << std::endl;
        std::exit(112);
    }
}
int main()
{
    test_scalblnl();
}
