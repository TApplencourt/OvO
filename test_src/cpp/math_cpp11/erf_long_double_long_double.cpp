#include <cmath>
#include <iomanip> 
#include <limits>
#include <iostream>
#include <cstdlib>
using namespace std;
bool almost_equal(long double x, long double y, int ulp) {
     return std::fabs(x-y) <= std::numeric_limits<long double>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<long double>::min();
}
void test_erf(){
   long double in0 {  0.42 };
   long double out1_host;
   long double out1_device;
    out1_host =  erf( in0);
   #pragma omp target map(from: out1_device )
   {
     out1_device =  erf( in0);
   }
   if ( !almost_equal(out1_host,out1_device, 4) ) {
        std::cerr << std::setprecision (std::numeric_limits<long double>::max_digits10 ) << "Host: " << out1_host << " GPU: " << out1_device << std::endl;
        std::exit(112);
    }
}
int main()
{
    test_erf();
}
