#include <cmath>
#include <iomanip>
#include <stdlib.h>
#include <limits>
#include <iostream>
#include <cstdlib>
using namespace std;
void test_ilogb(){
   const char* usr_precision = getenv("OVO_TOL_ULP");
   const int precision = usr_precision ? atoi(usr_precision) : 4;
   double x { 0.42 };
    int o_host {};
   int o_device {};
   {
    o_host = ilogb(x);
   }
   #pragma omp target map(tofrom: o_device )
   {
    o_device = ilogb(x);
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
