#include <cmath>
#include <iomanip>
#include <limits>
#include <iostream>
#include <cstdlib>
using namespace std;
bool almost_equal(float x, float y, int ulp) {
     return std::fabs(x-y) <= std::numeric_limits<float>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<float>::min();
}
void test_frexpf(){
    const int PROB_SIZE = 10;
   float in0 { 0.42 };
   int out1_host {};
   int out1_device {};
   float out2_host {};
   float out2_device {};
    for (int i= 0;  i < PROB_SIZE ; i++) {
    out2_host +=  frexpf( in0, &out1_host);
   }
   #pragma omp target map(tofrom: out1_device, out2_device )    reduction(+: out1_device)  reduction(+: out2_device)
    for (int i= 0;  i < PROB_SIZE; i++)
    {
     out2_device +=  frexpf( in0, &out1_device);
    }
   if ( out1_host != out1_device ) {
        std::cerr << std::setprecision (std::numeric_limits<int>::max_digits10 ) << "Host: " << out1_host << " GPU: " << out1_device << std::endl;
        std::exit(112);
    }
   if ( !almost_equal(out2_host,out2_device, 4) ) {
        std::cerr << std::setprecision (std::numeric_limits<float>::max_digits10 ) << "Host: " << out2_host << " GPU: " << out2_device << std::endl;
        std::exit(112);
    }
}
int main()
{
    test_frexpf();
}
