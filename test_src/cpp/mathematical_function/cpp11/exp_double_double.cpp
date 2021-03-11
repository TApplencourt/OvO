#include <cmath>
#include <iomanip>
#include <limits>
#include <iostream>
#include <cstdlib>
using namespace std;
bool almost_equal(double x, double y, int ulp) {
     return std::fabs(x-y) <= std::numeric_limits<double>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<double>::min();
}
void test_exp(){
    const int PROB_SIZE = 10;
   double in0 { 0.42 };
   double out1_host {};
   double out1_device {};
    for (int i= 0;  i < PROB_SIZE ; i++) {
    out1_host +=  exp( in0);
   }
   #pragma omp target map(tofrom: out1_device )    reduction(+: out1_device)
    for (int i= 0;  i < PROB_SIZE; i++)
    {
     out1_device +=  exp( in0);
    }
   if ( !almost_equal(out1_host,out1_device, 4) ) {
        std::cerr << std::setprecision (std::numeric_limits<double>::max_digits10 ) << "Host: " << out1_host << " GPU: " << out1_device << std::endl;
        std::exit(112);
    }
}
int main()
{
    test_exp();
}
