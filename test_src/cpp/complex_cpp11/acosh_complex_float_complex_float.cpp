
#include <complex>

#include <cmath>

#include <limits>
#include <iostream>
#include <stdexcept>
#
using namespace std;

 
bool almost_equal(complex<float> x, complex<float> y, int ulp) {

    return std::abs(x-y) <= std::numeric_limits<float>::epsilon() * std::abs(x+y) * ulp ||  std::abs(x-y) < std::numeric_limits<float>::min();

}


void test_acosh(){
   
   complex<float> x {  4.42, 0.0 };
   

   
   complex<float> o_host;
   complex<float> o_device;
   

    o_host =  acosh( x);
   
   #pragma omp target map(from: o_device )
   {
     o_device =  acosh( x);
   }

   
   if ( !almost_equal(o_host,o_device,1) ) {
        std::cerr << "Host: " << o_host << " GPU: " << o_device << std::endl;
        throw std::runtime_error( "acosh give incorect value when offloaded");
    }
    
}

int main()
{
    test_acosh();
}
