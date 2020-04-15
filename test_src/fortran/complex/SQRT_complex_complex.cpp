
#include <complex>

#include <cmath>

#include <limits>
#include <iostream>

using namespace std;

 
bool almost_equal(COMPLEX x, COMPLEX y, int ulp) {

    return std::abs(x-y) <= std::numeric_limits<REAL>::epsilon() * std::abs(x+y) * ulp ||  std::abs(x-y) < std::numeric_limits<REAL>::min();

}


void test_SQRT(){
   
   COMPLEX in0 {  0.42, 0.0 };
   

   
   COMPLEX out1_host;
   COMPLEX out1_device;
   

   out1_host = SQRT( in0);

   #pragma omp target map(from: out1_device )
   {
   out1_device = SQRT( in0);
   }

   
   if ( !almost_equal(out1_host,out1_device,1) ) {
        std::cerr << "Host: " << out1_host << " GPU: " << out1_device << std::endl;
        throw std::runtime_error( "SQRT give incorect value when offloaded");
    }
    
}

int main()
{
    test_SQRT();
}
