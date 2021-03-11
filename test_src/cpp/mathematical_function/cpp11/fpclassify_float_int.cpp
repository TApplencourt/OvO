#include <cmath>
#include <iomanip>
#include <limits>
#include <iostream>
#include <cstdlib>
using namespace std;
void test_fpclassify(){
    const int PROB_SIZE = 10;
   float in0 { 0.42 };
   int out1_host {};
   int out1_device {};
    for (int i= 0;  i < PROB_SIZE ; i++) {
    out1_host +=  fpclassify( in0);
   }
   #pragma omp target map(tofrom: out1_device )    reduction(+: out1_device)
    for (int i= 0;  i < PROB_SIZE; i++)
    {
     out1_device +=  fpclassify( in0);
    }
   if ( out1_host != out1_device ) {
        std::cerr << std::setprecision (std::numeric_limits<int>::max_digits10 ) << "Host: " << out1_host << " GPU: " << out1_device << std::endl;
        std::exit(112);
    }
}
int main()
{
    test_fpclassify();
}
