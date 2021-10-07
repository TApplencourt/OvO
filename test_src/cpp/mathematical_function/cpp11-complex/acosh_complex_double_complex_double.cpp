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
void test_acosh(){
   const char* usr_precision = getenv("OVO_TOL_ULP");
   const int precision = usr_precision ? atoi(usr_precision) : 4;
   complex<double> x { 4.42, 0.0 };
   complex<double> o_device {};
  #pragma omp target map(tofrom: o_device)
  {
    o_device = acosh(x);
  }
     if ( !almost_equal(cosh(o_device), x, 2*precision) ) {
            std::cerr << std::setprecision (std::numeric_limits<double>::max_digits10 ) << "Expected:" << x << " Got: " << cosh(o_device) << std::endl;
            std::exit(112);
     }
}
int main()
{
    test_acosh();
}
