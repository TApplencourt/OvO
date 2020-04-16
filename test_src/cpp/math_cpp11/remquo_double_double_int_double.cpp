
#include <cmath>

#include <limits>
#include <iostream>
#include <stdexcept>
#
using namespace std;

 
bool almost_equal(int x, int y, int ulp) {

    return x == y ; 

}
 
bool almost_equal(double x, double y, int ulp) {

     return std::fabs(x-y) <= std::numeric_limits<double>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<double>::min();

}


void test_remquo(){
   
   double in0 {  0.42 };
   
   double in1 {  0.42 };
   

   
   int out2_host;
   int out2_device;
   
   double out3_host;
   double out3_device;
   

    out3_host =  remquo( in0, in1, &out2_host);
   
   #pragma omp target map(from: out2_device, out3_device )
   {
     out3_device =  remquo( in0, in1, &out2_device);
   }

   
   if ( !almost_equal(out2_host,out2_device,1) ) {
        std::cerr << "Host: " << out2_host << " GPU: " << out2_device << std::endl;
        throw std::runtime_error( "remquo give incorect value when offloaded");
    }
    
   if ( !almost_equal(out3_host,out3_device,1) ) {
        std::cerr << "Host: " << out3_host << " GPU: " << out3_device << std::endl;
        throw std::runtime_error( "remquo give incorect value when offloaded");
    }
    
}

int main()
{
    test_remquo();
}
