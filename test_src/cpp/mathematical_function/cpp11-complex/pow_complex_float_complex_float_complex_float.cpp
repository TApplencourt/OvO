#include <complex>
#include <cmath>
#include <iomanip>
#include <limits>
#include <iostream>
#include <cstdlib>
using namespace std;
bool almost_equal(complex<float> x, complex<float> y, int ulp) {
    return std::abs(x-y) <= std::numeric_limits<float>::epsilon() * std::abs(x+y) * ulp ||  std::abs(x-y) < std::numeric_limits<float>::min();
}
void test_pow(){
   complex<float> in0 { 0.42, 0.0 };
   complex<float> in1 { 0.42, 0.0 };
    complex<float> out2_host {};
   complex<float> out2_device {};
   {
    out2_host =  pow(in0, in1);
   }
   #pragma omp target map(tofrom: out2_device )
   {
    out2_device =  pow(in0, in1);
   }
   if ( !almost_equal(out2_host,out2_device, 4) ) {
        std::cerr << std::setprecision (std::numeric_limits<float>::max_digits10 ) << "Host: " << out2_host << " GPU: " << out2_device << std::endl;
        std::exit(112);
    }
}
int main()
{
    test_pow();
}
