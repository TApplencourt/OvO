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
void test_atan(){
   const char* usr_precision = getenv("OVO_TOL_ULP");
   const int precision = usr_precision ? atoi(usr_precision) : 4;
   double in0 { 0.42 };
   double out1_device {};
   #pragma omp target map(tofrom: out1_device )
   {
    out1_device = atan(in0);
   }
   if ( !almost_equal(tan(out1_device), in0, 2*precision) ) {
            std::cerr << std::setprecision (std::numeric_limits<double>::max_digits10 ) << "Expected:" << in0 << " Got: " << tan(out1_device) << std::endl;
            std::exit(112);
   }
}
int main()
{
    test_atan();
}
