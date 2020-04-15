
#include <complex>

#include <cmath>

#include <limits>
#include <iostream>

using namespace std;

 
bool almost_equal(DOUBLE PRECISION x, DOUBLE PRECISION y, int ulp) {

     return std::fabs(x-y) <= std::numeric_limits<DOUBLE PRECISION>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<DOUBLE PRECISION>::min();

}


void test_DBLE(){
   
   COMPLEX in0 {  0.42, 0.0 };
   

   
   DOUBLE PRECISION out1_host;
   DOUBLE PRECISION out1_device;
   

   out1_host = DBLE( in0);

   #pragma omp target map(from: out1_device )
   {
   out1_device = DBLE( in0);
   }

   
   if ( !almost_equal(out1_host,out1_device,1) ) {
        std::cerr << "Host: " << out1_host << " GPU: " << out1_device << std::endl;
        throw std::runtime_error( "DBLE give incorect value when offloaded");
    }
    
}

int main()
{
    test_DBLE();
}
