#include <cmath>
#include <limits>
#include <iostream>
#include <cstdlib>
using namespace std;
bool almost_equal(float x, float y, int ulp) {
     return std::fabs(x-y) <= std::numeric_limits<float>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<float>::min();
}
void test_ellint_1f(){
   float in0 {  0.42 };
   float in1 {  0.42 };
   float out2_host;
   float out2_device;
    out2_host =  ellint_1f( in0, in1);
   #pragma omp target map(from: out2_device )
   {
     out2_device =  ellint_1f( in0, in1);
   }
   if ( !almost_equal(out2_host,out2_device, 4) ) {
        std::cerr << "Host: " << out2_host << " GPU: " << out2_device << std::endl;
        std::exit(112);
    }
}
int main()
{
    test_ellint_1f();
}
