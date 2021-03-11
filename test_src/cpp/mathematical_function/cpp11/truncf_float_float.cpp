#include <cmath>
#include <iomanip>
#include <limits>
#include <iostream>
#include <cstdlib>
using namespace std;
bool almost_equal(float x, float y, int ulp) {
     return std::fabs(x-y) <= std::numeric_limits<float>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<float>::min();
}
void test_truncf(){
    const int PROB_SIZE = 10;
   float in0 { 0.42 };
   float out1_host {};
   float out1_device {};
    for (int i= 0;  i < PROB_SIZE ; i++) {
    out1_host +=  truncf( in0);
   }
   #pragma omp target map(tofrom: out1_device )    reduction(+: out1_device)
    for (int i= 0;  i < PROB_SIZE; i++)
    {
     out1_device +=  truncf( in0);
    }
   if ( !almost_equal(out1_host,out1_device, 4) ) {
        std::cerr << std::setprecision (std::numeric_limits<float>::max_digits10 ) << "Host: " << out1_host << " GPU: " << out1_device << std::endl;
        std::exit(112);
    }
}
int main()
{
    test_truncf();
}
