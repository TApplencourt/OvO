
#include <cmath>

#include <limits>
#include <iostream>

using namespace std;

 
bool almost_equal(double x, double y, int ulp) {

     return std::fabs(x-y) <= std::numeric_limits<double>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<double>::min();

}


void test_assoc_legendre(){
   
   unsigned in0 {  1 };
   
   unsigned in1 {  1 };
   
   double in2 {  0.42 };
   

   
   double out3_host;
   double out3_device;
   

   out3_host = assoc_legendre( in0, in1, in2);

   #pragma omp target map(from: out3_device )
   {
   out3_device = assoc_legendre( in0, in1, in2);
   }

   
   if ( !almost_equal(out3_host,out3_device,1) ) {
        std::cerr << "Host: " << out3_host << " GPU: " << out3_device << std::endl;
        throw std::runtime_error( "assoc_legendre give incorect value when offloaded");
    }
    
}

int main()
{
    test_assoc_legendre();
}
