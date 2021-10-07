#include <cmath>
#include <iomanip>
#include <stdlib.h>
#include <limits>
#include <iostream>
#include <cstdlib>
using namespace std;
void test_isless(){
   const char* usr_precision = getenv("OVO_TOL_ULP");
   const int precision = usr_precision ? atoi(usr_precision) : 4;
   float in0 { 0.42 };
   float in1 { 0.42 };
    bool out2_host {};
   bool out2_device {};
   {
    out2_host = isless(in0, in1);
   }
   #pragma omp target map(tofrom: out2_device )
   #pragma omp simd
   {
    out2_device = isless(in0, in1);
   }
   if ( out2_host != out2_device ) {
        std::cerr << std::setprecision (std::numeric_limits<bool>::max_digits10 ) << "Host: " << out2_host << " GPU: " << out2_device << std::endl;
        std::exit(112);
    }
}
int main()
{
    test_isless();
}
