#include <complex>
#include <cmath>
#include <limits>
#include <iostream>
#include <cstdlib>
using namespace std;
bool almost_equal(complex<double> x, complex<double> y, int ulp) {
    return std::abs(x-y) <= std::numeric_limits<double>::epsilon() * std::abs(x+y) * ulp ||  std::abs(x-y) < std::numeric_limits<double>::min();
}
void test_tan(){
   complex<double> in0 {  0.42, 0.0 };
   complex<double> out1_host;
   complex<double> out1_device;
    out1_host =  tan( in0);
   #pragma omp target map(from: out1_device )
   {
     out1_device =  tan( in0);
   }
   if ( !almost_equal(out1_host,out1_device, 4) ) {
        std::cerr << "Host: " << out1_host << " GPU: " << out1_device << std::endl;
        std::exit(112);
    }
}
int main()
{
    test_tan();
}
