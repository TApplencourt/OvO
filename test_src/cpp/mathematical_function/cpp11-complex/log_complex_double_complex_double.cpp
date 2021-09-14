#include <complex>
#include <cmath>
#include <iomanip>
#include <limits>
#include <iostream>
#include <cstdlib>
using namespace std;
bool almost_equal(complex<double> x, complex<double> y, int ulp) {
    return std::abs(x-y) <= std::numeric_limits<double>::epsilon() * std::abs(x+y) * ulp ||  std::abs(x-y) < std::numeric_limits<double>::min();
}
void test_log(){
   complex<double> in0 { 0.42, 0.0 };
   complex<double> out1_device {};
   #pragma omp target map(tofrom: out1_device )
   {
    out1_device =  log(in0);
   }
   if ( !almost_equal(exp(out1_device), in0, 16) ) {
            std::cerr << std::setprecision (std::numeric_limits<double>::max_digits10 ) << "Expected:" << in0 << " Got: "  << exp(out1_device) << std::endl;
            std::exit(112);
   }
}
int main()
{
    test_log();
}
