#include <cmath>
#include <limits>
#include <iostream>
#include <cstdlib>
using namespace std;
bool almost_equal(float x, float y, int ulp) {
     return std::fabs(x-y) <= std::numeric_limits<float>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<float>::min();
}
void test_sqrt(){
   float x {  0.42 };
   float o_host;
   float o_device;
    o_host =  sqrt( x);
   #pragma omp target map(from: o_device )
   {
     o_device =  sqrt( x);
   }
   if ( !almost_equal(o_host,o_device, 4) ) {
        std::cerr << "Host: " << o_host << " GPU: " << o_device << std::endl;
        std::exit(112);
    }
}
int main()
{
    test_sqrt();
}