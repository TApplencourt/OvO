#include <complex>
#include <cmath>
#include <iomanip>
#include <stdlib.h>
#include <limits>
#include <iostream>
#include <cstdlib>
using namespace std;
bool almost_equal(complex<double> x, complex<double> y, int ulp) {
   return std::abs(x-y) <= std::numeric_limits<double>::epsilon() * std::abs(x+y) * ulp || std::abs(x-y) < std::numeric_limits<double>::min();
}
void test_pow(){
   const char* usr_precision = getenv("OVO_TOL_ULP");
   const int precision = usr_precision ? atoi(usr_precision) : 4;
   complex<double> in0 { 0.42, 0.0 };
   complex<double> in1 { 0.42, 0.0 };
   complex<double> out2_host {};
   complex<double> out2_device {};
   {
      out2_host = pow(in0, in1);
   }
   #pragma omp target map(from: out2_device)
   {
      out2_device = pow(in0, in1);
   }
   {
      if ( !almost_equal(out2_host,out2_device, precision) ) {
          std::cerr << std::setprecision (std::numeric_limits<double>::max_digits10 )
                    << "Host: " << out2_host << " GPU: " << out2_device << std::endl;
          std::exit(112);
      }
   }
}
int main()
{
    test_pow();
}
