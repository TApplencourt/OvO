#include <cmath>
#include <iomanip>
#include <stdlib.h>
#include <limits>
#include <iostream>
#include <cstdlib>
using namespace std;
void test_abs(){
   const char* usr_precision = getenv("OVO_TOL_ULP");
   const int precision = usr_precision ? atoi(usr_precision) : 4;
   int in0 { 1 };
   int out1_host {};
   int out1_device {};
   {
      out1_host = abs(in0);
   }
   #pragma omp target map(from: out1_device)
   {
      out1_device = abs(in0);
   }
   {
      if ( out1_host != out1_device ) {
          std::cerr << std::setprecision (std::numeric_limits<int>::max_digits10 )
                    << "Host: " << out1_host << " GPU: " << out1_device << std::endl;
          std::exit(112);
      }
   }
}
int main()
{
    test_abs();
}
