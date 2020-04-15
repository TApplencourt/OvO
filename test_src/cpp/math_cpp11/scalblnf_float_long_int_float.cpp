
#include <cmath>

#include <limits>
#include <iostream>

using namespace std;

 
bool almost_equal(float x, float y, int ulp) {

     return std::fabs(x-y) <= std::numeric_limits<float>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<float>::min();

}


void test_scalblnf(){
   
   float in0 {  0.42 };
   
   long int in1 {  1 };
   

   
   float out2_host;
   float out2_device;
   

   out2_host = scalblnf( in0, in1);

   #pragma omp target map(from: out2_device )
   {
   out2_device = scalblnf( in0, in1);
   }

   
   if ( !almost_equal(out2_host,out2_device,1) ) {
        std::cerr << "Host: " << out2_host << " GPU: " << out2_device << std::endl;
        throw std::runtime_error( "scalblnf give incorect value when offloaded");
    }
    
}

int main()
{
    test_scalblnf();
}
