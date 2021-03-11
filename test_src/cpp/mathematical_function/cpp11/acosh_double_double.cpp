#include <cmath>
#include <iomanip>
#include <limits>
#include <iostream>
#include <cstdlib>
using namespace std;
bool almost_equal(double x, double y, int ulp) {
     return std::fabs(x-y) <= std::numeric_limits<double>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<double>::min();
}
void test_acosh(){
    const int PROB_SIZE = 10;
   double x { 4.42 };
   double o_host {};
   double o_device {};
    for (int i= 0;  i < PROB_SIZE ; i++) {
    o_host +=  acosh( x);
   }
   #pragma omp target map(tofrom: o_device )    reduction(+: o_device)
    for (int i= 0;  i < PROB_SIZE; i++)
    {
     o_device +=  acosh( x);
    }
   if ( !almost_equal(o_host,o_device, 4) ) {
        std::cerr << std::setprecision (std::numeric_limits<double>::max_digits10 ) << "Host: " << o_host << " GPU: " << o_device << std::endl;
        std::exit(112);
    }
}
int main()
{
    test_acosh();
}
