
#include <complex>

#include <cmath>

#include <limits>
#include <iostream>

using namespace std;

 
bool almost_equal(complex<float> x, complex<float> y, int ulp) {

    return std::abs(x-y) <= std::numeric_limits<float>::epsilon() * std::abs(x+y) * ulp ||  std::abs(x-y) < std::numeric_limits<float>::min();

}


void test_atan(){
   
   complex<float> in0 {  0.42, 0.0 };
   

   
   complex<float> out1_host;
   complex<float> out1_device;
   

   out1_host = atan( in0);

   #pragma omp target map(from: out1_device )
   {
   out1_device = atan( in0);
   }

   
   if ( !almost_equal(out1_host,out1_device,1) ) {
        std::cerr << "Host: " << out1_host << " GPU: " << out1_device << std::endl;
        throw std::runtime_error( "atan give incorect value when offloaded");
    }
    
}

int main()
{
    test_atan();
}
