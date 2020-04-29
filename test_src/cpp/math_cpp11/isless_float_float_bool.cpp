#include <cmath>
#include <limits>
#include <iostream>
#include <cstdlib>
using namespace std;
bool almost_equal(bool x, bool y, int ulp) {
    return x == y ; 
}
void test_isless(){
   float in0 {  0.42 };
   float in1 {  0.42 };
   bool out2_host;
   bool out2_device;
    out2_host =  isless( in0, in1);
   #pragma omp target map(from: out2_device )
   {
     out2_device =  isless( in0, in1);
   }
   if ( !almost_equal(out2_host,out2_device, 4) ) {
        std::cerr << "Host: " << out2_host << " GPU: " << out2_device << std::endl;
        std::exit(112);
    }
}
int main()
{
    test_isless();
}
