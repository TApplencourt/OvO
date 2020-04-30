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
void test_acosh(){
   complex<long double> x {  4.42, 0.0 };
   complex<long double> o_host;
   complex<long double> o_device;
    o_host =  acosh( x);
   #pragma omp target map(from: o_device )
   {
     o_device =  acosh( x);
   }
   if ( !almost_equal(o_host,o_device, 4) ) {
        std::cerr << std::setprecision (std::numeric_limits<long double>::max_digits10 ) << "Host: " << o_host << " GPU: " << o_device << std::endl;
        std::exit(112);
    }
}
int main()
{
    test_acosh();
}