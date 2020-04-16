
#include <cmath>

#include <limits>
#include <iostream>
#include <stdexcept>
#
using namespace std;

 
bool almost_equal(float x, float y, int ulp) {

     return std::fabs(x-y) <= std::numeric_limits<float>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<float>::min();

}


void test_modff(){
   
   float in0 {  0.42 };
   

   
   float out1_host;
   float out1_device;
   
   float out2_host;
   float out2_device;
   

    out2_host =  modff( in0, &out1_host);
   
   #pragma omp target map(from: out1_device, out2_device )
   {
     out2_device =  modff( in0, &out1_device);
   }

   
   if ( !almost_equal(out1_host,out1_device,1) ) {
        std::cerr << "Host: " << out1_host << " GPU: " << out1_device << std::endl;
        throw std::runtime_error( "modff give incorect value when offloaded");
    }
    
   if ( !almost_equal(out2_host,out2_device,1) ) {
        std::cerr << "Host: " << out2_host << " GPU: " << out2_device << std::endl;
        throw std::runtime_error( "modff give incorect value when offloaded");
    }
    
}

int main()
{
    test_modff();
}
