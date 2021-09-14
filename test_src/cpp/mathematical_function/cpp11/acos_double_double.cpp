#include <cmath>
#include <iomanip>
#include <limits>
#include <iostream>
#include <cstdlib>
using namespace std;
bool almost_equal(double x, double y, int ulp) {
     return std::fabs(x-y) <= std::numeric_limits<double>::epsilon() * std::fabs(x+y) * ulp || std::fabs(x-y) < std::numeric_limits<double>::min();
}
void test_acos(){
   double x { 0.42 };
   double o_device {};
   #pragma omp target map(tofrom: o_device )
   {
    o_device = acos(x);
   }
   if ( !almost_equal(cos(o_device), x, 16) ) {
            std::cerr << std::setprecision (std::numeric_limits<double>::max_digits10 ) << "Expected:" << x << " Got: " << cos(o_device) << std::endl;
            std::exit(112);
   }
}
int main()
{
    test_acos();
}
