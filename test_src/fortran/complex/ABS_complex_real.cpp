
#include <complex>

#include <cmath>

#include <limits>
#include <iostream>

using namespace std;

 
bool almost_equal(REAL x, REAL y, int ulp) {

     return std::fabs(x-y) <= std::numeric_limits<REAL>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<REAL>::min();

}


void test_ABS(){
   
   COMPLEX in0 {  0.42, 0.0 };
   

   
   REAL out1_host;
   REAL out1_device;
   

   out1_host = ABS( in0);

   #pragma omp target map(from: out1_device )
   {
   out1_device = ABS( in0);
   }

   
   if ( !almost_equal(out1_host,out1_device,1) ) {
        std::cerr << "Host: " << out1_host << " GPU: " << out1_device << std::endl;
        throw std::runtime_error( "ABS give incorect value when offloaded");
    }
    
}

int main()
{
    test_ABS();
}
