#include <cmath>
#include <iomanip> 
#include <limits>
#include <iostream>
#include <cstdlib>
using namespace std;
bool almost_equal(long long int x, long long int y, int ulp) {
    return x == y ; 
}
void test_llround(){
   long double in0 {  0.42 };
   long long int out1_host;
   long long int out1_device;
    out1_host =  llround( in0);
   #pragma omp target map(from: out1_device )
   {
     out1_device =  llround( in0);
   }
   if ( !almost_equal(out1_host,out1_device, 4) ) {
        std::cerr << std::setprecision (std::numeric_limits<long long int>::max_digits10 ) << "Host: " << out1_host << " GPU: " << out1_device << std::endl;
        std::exit(112);
    }
}
int main()
{
    test_llround();
}
