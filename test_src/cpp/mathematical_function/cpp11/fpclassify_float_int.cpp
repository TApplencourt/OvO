#include <cmath>
#include <iomanip>
#include <limits>
#include <iostream>
#include <cstdlib>
using namespace std;
bool almost_equal(int x, int y, int ulp) {
    return x == y ;
}
void test_fpclassify(){
   float in0 {  0.42 };
   int out1_host;
   int out1_device;
    out1_host =  fpclassify( in0);
   #pragma omp target map(from: out1_device )
   {
     out1_device =  fpclassify( in0);
   }
   if ( !almost_equal(out1_host,out1_device, 4) ) {
        std::cerr << std::setprecision (std::numeric_limits<int>::max_digits10 ) << "Host: " << out1_host << " GPU: " << out1_device << std::endl;
        std::exit(112);
    }
}
int main()
{
    test_fpclassify();
}
