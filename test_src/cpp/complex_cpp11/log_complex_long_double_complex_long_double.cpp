#include <complex>
#include <cmath>
#include <iomanip> 
#include <limits>
#include <iostream>
#include <cstdlib>
using namespace std;
bool almost_equal(complex<long double> x, complex<long double> y, int ulp) {
    return std::abs(x-y) <= std::numeric_limits<long double>::epsilon() * std::abs(x+y) * ulp ||  std::abs(x-y) < std::numeric_limits<long double>::min();
}
void test_log(){
   complex<long double> in0 {  0.42, 0.0 };
   complex<long double> out1_host;
   complex<long double> out1_device;
    out1_host =  log( in0);
   #pragma omp target map(from: out1_device )
   {
     out1_device =  log( in0);
   }
   if ( !almost_equal(out1_host,out1_device, 4) ) {
        std::cerr << std::setprecision (std::numeric_limits<long double>::max_digits10 ) << "Host: " << out1_host << " GPU: " << out1_device << std::endl;
        std::exit(112);
    }
}
int main()
{
    test_log();
}
