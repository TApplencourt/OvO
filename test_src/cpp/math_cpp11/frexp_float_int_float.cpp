#include <cmath>
#include <limits>
#include <iostream>
#include <stdexcept>
#
using namespace std;
bool almost_equal(int x, int y, int ulp) {
    return x == y ; 
}
bool almost_equal(float x, float y, int ulp) {
     return std::fabs(x-y) <= std::numeric_limits<float>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<float>::min();
}
void test_frexp(){
   float in0 {  0.42 };
   int out1_host;
   int out1_device;
   float out2_host;
   float out2_device;
    out2_host =  frexp( in0, &out1_host);
   #pragma omp target map(from: out1_device, out2_device )
   {
     out2_device =  frexp( in0, &out1_device);
   }
   if ( !almost_equal(out1_host,out1_device,1) ) {
        std::cerr << "Host: " << out1_host << " GPU: " << out1_device << std::endl;
        throw std::runtime_error( "frexp give incorect value when offloaded");
    }
   if ( !almost_equal(out2_host,out2_device,1) ) {
        std::cerr << "Host: " << out2_host << " GPU: " << out2_device << std::endl;
        throw std::runtime_error( "frexp give incorect value when offloaded");
    }
}
int main()
{
    test_frexp();
}
