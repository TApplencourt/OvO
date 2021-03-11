#include <cmath>
#include <iomanip>
#include <limits>
#include <iostream>
#include <cstdlib>
using namespace std;
void test_ilogb(){
    const int PROB_SIZE = 10;
   double x { 0.42 };
   int o_host {};
   int o_device {};
    for (int i= 0;  i < PROB_SIZE ; i++) {
    o_host +=  ilogb( x);
   }
   #pragma omp target map(tofrom: o_device )    reduction(+: o_device)
    for (int i= 0;  i < PROB_SIZE; i++)
    {
     o_device +=  ilogb( x);
    }
   if ( o_host != o_device ) {
        std::cerr << std::setprecision (std::numeric_limits<int>::max_digits10 ) << "Host: " << o_host << " GPU: " << o_device << std::endl;
        std::exit(112);
    }
}
int main()
{
    test_ilogb();
}
