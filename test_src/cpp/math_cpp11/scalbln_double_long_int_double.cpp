#include <cmath>
#include <limits>
#include <iostream>
#include <stdexcept>
#
using namespace std;
bool almost_equal(double x, double y, int ulp) {
     return std::fabs(x-y) <= std::numeric_limits<double>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<double>::min();
}
void test_scalbln(){
   double in0 {  0.42 };
   long int in1 {  1 };
   double out2_host;
   double out2_device;
    out2_host =  scalbln( in0, in1);
   #pragma omp target map(from: out2_device )
   {
     out2_device =  scalbln( in0, in1);
   }
   if ( !almost_equal(out2_host,out2_device,1) ) {
        std::cerr << "Host: " << out2_host << " GPU: " << out2_device << std::endl;
        throw std::runtime_error( "scalbln give incorect value when offloaded");
    }
}
int main()
{
    test_scalbln();
}
