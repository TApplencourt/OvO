#include <cmath>
#include <iomanip>
#include <stdlib.h>
#include <limits>
#include <iostream>
#include <cstdlib>
using namespace std;
bool almost_equal(double x, double y, int ulp) {
     return std::fabs(x-y) <= std::numeric_limits<double>::epsilon() * std::fabs(x+y) * ulp || std::fabs(x-y) < std::numeric_limits<double>::min();
}
void test_frexp(){
   const char* usr_precision = getenv("OVO_TOL_ULP");
   const int precision = usr_precision ? atoi(usr_precision) : 4;
   double in0 { 0.42 };
    int out1_host {};
   int out1_device {};
    double out2_host {};
   double out2_device {};
{
    out2_host = frexp(in0, &out1_host);
}
  #pragma omp target map(tofrom: out1_device, out2_device)
  {
    out2_device = frexp(in0, &out1_device);
  }
           if ( out1_host != out1_device ) {
             std::cerr << std::setprecision (std::numeric_limits<int>::max_digits10 ) << "Host: " << out1_host << " GPU: " << out1_device << std::endl;
        std::exit(112);
           }
           if ( !almost_equal(out2_host,out2_device, precision) ) {
             std::cerr << std::setprecision (std::numeric_limits<double>::max_digits10 ) << "Host: " << out2_host << " GPU: " << out2_device << std::endl;
        std::exit(112);
           }
}
int main()
{
    test_frexp();
}
