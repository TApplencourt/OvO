#include <cmath>
#include <iomanip>
#include <limits>
#include <iostream>
#include <cstdlib>
using namespace std;
bool almost_equal(double x, double y, int ulp) {
     return std::fabs(x-y) <= std::numeric_limits<double>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<double>::min();
}
void test_remquo(){
   double in0 { 0.42 };
   double in1 { 0.42 };
   int out2_host {};
   int out2_device {};
   double out3_host {};
   double out3_device {};
   {
    out3_host =  remquo(in0, in1, &out2_host);
   }
   #pragma omp target map(tofrom: out2_device, out3_device )
   {
     out3_device =  remquo(in0, in1, &out2_device);
   }
   if ( out2_host != out2_device ) {
        std::cerr << std::setprecision (std::numeric_limits<int>::max_digits10 ) << "Host: " << out2_host << " GPU: " << out2_device << std::endl;
        std::exit(112);
    }
   if ( !almost_equal(out3_host,out3_device, 4) ) {
        std::cerr << std::setprecision (std::numeric_limits<double>::max_digits10 ) << "Host: " << out3_host << " GPU: " << out3_device << std::endl;
        std::exit(112);
    }
}
int main()
{
    test_remquo();
}
