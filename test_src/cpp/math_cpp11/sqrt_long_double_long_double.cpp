#include <cmath>
#include <iomanip> 
#include <limits>
#include <iostream>
#include <cstdlib>
using namespace std;
bool almost_equal(long double x, long double y, int ulp) {
     return std::fabs(x-y) <= std::numeric_limits<long double>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<long double>::min();
}
void test_sqrt(){
   long double x {  0.42 };
   long double o_host;
   long double o_device;
    o_host =  sqrt( x);
   #pragma omp target map(from: o_device )
   {
     o_device =  sqrt( x);
   }
   if ( !almost_equal(o_host,o_device, 4) ) {
        std::cerr << std::setprecision (std::numeric_limits<long double>::max_digits10 ) << "Host: " << o_host << " GPU: " << o_device << std::endl;
        std::exit(112);
    }
}
int main()
{
    test_sqrt();
}
