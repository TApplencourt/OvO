#include <cmath>
#include <iomanip>
#include <limits>
#include <iostream>
#include <cstdlib>
using namespace std;
void test_isfinite(){
   float in0 { 0.42 };
    bool out1_host {};
   bool out1_device {};
   {
    out1_host = isfinite(in0);
   }
   #pragma omp target map(tofrom: out1_device )
   {
    out1_device = isfinite(in0);
   }
   if ( out1_host != out1_device ) {
        std::cerr << std::setprecision (std::numeric_limits<bool>::max_digits10 ) << "Host: " << out1_host << " GPU: " << out1_device << std::endl;
        std::exit(112);
    }
}
int main()
{
    test_isfinite();
}
