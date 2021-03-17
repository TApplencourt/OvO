#include <cmath>
#include <iomanip>
#include <limits>
#include <iostream>
#include <cstdlib>
using namespace std;
bool almost_equal(float x, float y, int ulp) {
     return std::fabs(x-y) <= std::numeric_limits<float>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<float>::min();
}
void test_lgamma(){
   float x { 0.42 };
   float o_host {};
   float o_device {};
   {
    o_host =  lgamma(x);
   }
   #pragma omp target map(tofrom: o_device )
   {
     o_device =  lgamma(x);
   }
   if ( !almost_equal(o_host,o_device, 4) ) {
        std::cerr << std::setprecision (std::numeric_limits<float>::max_digits10 ) << "Host: " << o_host << " GPU: " << o_device << std::endl;
        std::exit(112);
    }
}
int main()
{
    test_lgamma();
}
