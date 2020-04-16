
#include <cmath>

#include <limits>
#include <iostream>
#include <stdexcept>
#
using namespace std;

 
bool almost_equal(float x, float y, int ulp) {

     return std::fabs(x-y) <= std::numeric_limits<float>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<float>::min();

}


void test_cyl_bessel_if(){
   
   float in0 {  0.42 };
   
   float in1 {  0.42 };
   

   
   float out2_host;
   float out2_device;
   

    out2_host =  cyl_bessel_if( in0, in1);
   
   #pragma omp target map(from: out2_device )
   {
     out2_device =  cyl_bessel_if( in0, in1);
   }

   
   if ( !almost_equal(out2_host,out2_device,1) ) {
        std::cerr << "Host: " << out2_host << " GPU: " << out2_device << std::endl;
        throw std::runtime_error( "cyl_bessel_if give incorect value when offloaded");
    }
    
}

int main()
{
    test_cyl_bessel_if();
}
