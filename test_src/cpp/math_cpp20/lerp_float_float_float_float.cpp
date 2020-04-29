#include <cmath>
#include <limits>
#include <iostream>
#include <cstdlib>
using namespace std;
bool almost_equal(float x, float y, int ulp) {
     return std::fabs(x-y) <= std::numeric_limits<float>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<float>::min();
}
void test_lerp(){
   float in0 {  0.42 };
   float in1 {  0.42 };
   float in2 {  0.42 };
   float out3_host;
   float out3_device;
    out3_host =  lerp( in0, in1, in2);
   #pragma omp target map(from: out3_device )
   {
     out3_device =  lerp( in0, in1, in2);
   }
   if ( !almost_equal(out3_host,out3_device, 4) ) {
        std::cerr << "Host: " << out3_host << " GPU: " << out3_device << std::endl;
        std::exit(112);
    }
}
int main()
{
    test_lerp();
}
