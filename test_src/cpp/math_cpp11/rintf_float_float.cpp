
#include <cmath>

#include <limits>
#include <iostream>
#include <stdexcept>
#
using namespace std;

 
bool almost_equal(float x, float y, int ulp) {

     return std::fabs(x-y) <= std::numeric_limits<float>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<float>::min();

}


void test_rintf(){
   
   float in0 {  0.42 };
   

   
   float out1_host;
   float out1_device;
   

    out1_host =  rintf( in0);
   
   #pragma omp target map(from: out1_device )
   {
     out1_device =  rintf( in0);
   }

   
   if ( !almost_equal(out1_host,out1_device,1) ) {
        std::cerr << "Host: " << out1_host << " GPU: " << out1_device << std::endl;
        throw std::runtime_error( "rintf give incorect value when offloaded");
    }
    
}

int main()
{
    test_rintf();
}
