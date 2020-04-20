#include <complex>
#include <cmath>
#include <limits>
#include <iostream>
#include <stdexcept>
#
using namespace std;
bool almost_equal(complex<long double> x, complex<long double> y, int ulp) {
    return std::abs(x-y) <= std::numeric_limits<long double>::epsilon() * std::abs(x+y) * ulp ||  std::abs(x-y) < std::numeric_limits<long double>::min();
}
void test_pow(){
   complex<long double> in0 {  0.42, 0.0 };
   complex<long double> in1 {  0.42, 0.0 };
   complex<long double> out2_host;
   complex<long double> out2_device;
    out2_host =  pow( in0, in1);
   #pragma omp target map(from: out2_device )
   {
     out2_device =  pow( in0, in1);
   }
   if ( !almost_equal(out2_host,out2_device,1) ) {
        std::cerr << "Host: " << out2_host << " GPU: " << out2_device << std::endl;
        throw std::runtime_error( "pow give incorect value when offloaded");
    }
}
int main()
{
    test_pow();
}
