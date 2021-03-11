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
void test_asin(){
    const int PROB_SIZE = 10;
   complex<double> x { 0.42, 0.0 };
   complex<double> o_host {};
   complex<double> o_device {};
    for (int i= 0;  i < PROB_SIZE ; i++) {
    o_host +=  asin( x);
   }
   #pragma omp target map(tofrom: o_device )    reduction(+: o_device)
    for (int i= 0;  i < PROB_SIZE; i++)
    {
     o_device +=  asin( x);
    }
   if ( !almost_equal(o_host,o_device, 4) ) {
        std::cerr << std::setprecision (std::numeric_limits<double>::max_digits10 ) << "Host: " << o_host << " GPU: " << o_device << std::endl;
        std::exit(112);
    }
}
int main()
{
    test_asin();
}
