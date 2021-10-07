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
void test_log(){
   const char* usr_precision = getenv("OVO_TOL_ULP");
   const int precision = usr_precision ? atoi(usr_precision) : 4;
   complex<float> in0 { 0.42, 0.0 };
   complex<float> out1_device {};
   #pragma omp target map(tofrom: out1_device )
   #pragma omp simd
   {
    out1_device = log(in0);
   }
   if ( !almost_equal(exp(out1_device), in0, 2*precision) ) {
            std::cerr << std::setprecision (std::numeric_limits<float>::max_digits10 ) << "Expected:" << in0 << " Got: " << exp(out1_device) << std::endl;
            std::exit(112);
   }
}
int main()
{
    test_log();
}
