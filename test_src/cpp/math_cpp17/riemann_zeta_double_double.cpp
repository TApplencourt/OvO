#include <cmath>
#include <limits>
#include <iostream>
#include <cstdlib>
using namespace std;
bool almost_equal(double x, double y, int ulp) {
     return std::fabs(x-y) <= std::numeric_limits<double>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<double>::min();
}
void test_riemann_zeta(){
   double in0 {  0.42 };
   double out1_host;
   double out1_device;
    out1_host =  riemann_zeta( in0);
   #pragma omp target map(from: out1_device )
   {
     out1_device =  riemann_zeta( in0);
   }
   if ( !almost_equal(out1_host,out1_device, 4) ) {
        std::cerr << "Host: " << out1_host << " GPU: " << out1_device << std::endl;
        std::exit(112);
    }
}
int main()
{
    test_riemann_zeta();
}
