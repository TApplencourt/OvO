#include <complex>
#include <cmath>
#include <limits>
#include <iostream>
#include <stdexcept>
#
using namespace std;
bool almost_equal(complex<double> x, complex<double> y, int ulp) {
    return std::abs(x-y) <= std::numeric_limits<double>::epsilon() * std::abs(x+y) * ulp ||  std::abs(x-y) < std::numeric_limits<double>::min();
}
void test_acos(){
   complex<double> x {  4.42, 0.0 };
   complex<double> o_host;
   complex<double> o_device;
    o_host =  acos( x);
   #pragma omp target map(from: o_device )
   {
     o_device =  acos( x);
   }
   if ( !almost_equal(o_host,o_device,4) ) {
        std::cerr << "Host: " << o_host << " GPU: " << o_device << std::endl;
        throw std::runtime_error( "acos give incorect value when offloaded");
    }
}
int main()
{
    test_acos();
}
