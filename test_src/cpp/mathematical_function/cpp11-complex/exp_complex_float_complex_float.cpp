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
void test_exp(){
    const int PROB_SIZE = 10;
   complex<float> in0 { 0.42, 0.0 };
   complex<float> out1_host {};
   complex<float> out1_device {};
    for (int i= 0;  i < PROB_SIZE ; i++) {
    out1_host +=  exp( in0);
   }
   #pragma omp target map(tofrom: out1_device )    reduction(+: out1_device)
    for (int i= 0;  i < PROB_SIZE; i++)
    {
     out1_device +=  exp( in0);
    }
   if ( !almost_equal(out1_host,out1_device, 4) ) {
        std::cerr << std::setprecision (std::numeric_limits<float>::max_digits10 ) << "Host: " << out1_host << " GPU: " << out1_device << std::endl;
        std::exit(112);
    }
}
int main()
{
    test_exp();
}
