#include <cmath>
#include <iomanip>
#include <limits>
#include <iostream>
#include <cstdlib>
using namespace std;
bool almost_equal(float x, float y, int ulp) {
     return std::fabs(x-y) <= std::numeric_limits<float>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<float>::min();
}
void test_scalbnf(){
    const int PROB_SIZE = 10;
   float in0 { 0.42 };
   int in1 { 1 };
   float out2_host {};
   float out2_device {};
    for (int i= 0;  i < PROB_SIZE ; i++) {
    out2_host +=  scalbnf( in0, in1);
   }
   #pragma omp target map(tofrom: out2_device )    reduction(+: out2_device)
    for (int i= 0;  i < PROB_SIZE; i++)
    {
     out2_device +=  scalbnf( in0, in1);
    }
   if ( !almost_equal(out2_host,out2_device, 4) ) {
        std::cerr << std::setprecision (std::numeric_limits<float>::max_digits10 ) << "Host: " << out2_host << " GPU: " << out2_device << std::endl;
        std::exit(112);
    }
}
int main()
{
    test_scalbnf();
}
