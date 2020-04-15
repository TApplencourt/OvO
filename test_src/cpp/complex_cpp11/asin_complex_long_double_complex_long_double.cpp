
#include <complex>

#include <cmath>

#include <limits>
#include <iostream>

using namespace std;

 
bool almost_equal(complex<long double> x, complex<long double> y, int ulp) {

    return std::abs(x-y) <= std::numeric_limits<long double>::epsilon() * std::abs(x+y) * ulp ||  std::abs(x-y) < std::numeric_limits<long double>::min();

}


void test_asin(){
   
   complex<long double> x {  0.42, 0.0 };
   

   
   complex<long double> o_host;
   complex<long double> o_device;
   

   o_host = asin( x);

   #pragma omp target map(from: o_device )
   {
   o_device = asin( x);
   }

   
   if ( !almost_equal(o_host,o_device,1) ) {
        std::cerr << "Host: " << o_host << " GPU: " << o_device << std::endl;
        throw std::runtime_error( "asin give incorect value when offloaded");
    }
    
}

int main()
{
    test_asin();
}
