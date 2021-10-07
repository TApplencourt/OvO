#include <complex>
#include <cmath>
#include <iomanip>
#include <stdlib.h>
#include <limits>
#include <iostream>
#include <cstdlib>
using namespace std;
bool almost_equal(complex<float> x, complex<float> y, int ulp) {
    return std::abs(x-y) <= std::numeric_limits<float>::epsilon() * std::abs(x+y) * ulp || std::abs(x-y) < std::numeric_limits<float>::min();
}
void test_log10(){
   const char* usr_precision = getenv("OVO_TOL_ULP");
   const int precision = usr_precision ? atoi(usr_precision) : 4;
   complex<float> in0 { 0.42, 0.0 };
    complex<float> out1_host {};
   complex<float> out1_device {};
   {
    out1_host = log10(in0);
   }
   #pragma omp target map(tofrom: out1_device )
   #pragma omp simd
   {
    out1_device = log10(in0);
   }
   if ( !almost_equal(out1_host,out1_device, precision) ) {
        std::cerr << std::setprecision (std::numeric_limits<float>::max_digits10 ) << "Host: " << out1_host << " GPU: " << out1_device << std::endl;
        std::exit(112);
    }
}
int main()
{
    test_log10();
}
