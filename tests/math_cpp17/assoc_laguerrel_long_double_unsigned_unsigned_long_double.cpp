
#include <cmath>


#include <limits>
#include <iostream>
#include <stdexcept>

using namespace std;

bool almost_equal(long double x, long double y, int ulp) {

     return std::fabs(x-y) <= std::numeric_limits<long double>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<long double>::min();

}

void test_assoc_laguerrel(){
   
   unsigned n {  1 };
   
   unsigned m {  1 };
   
   long double x {  0.42 };
   

   long double o_host = assoc_laguerrel( n, m, x);

   long double o_gpu ; 
   #pragma omp target defaultmap(tofrom:scalar)
   {
   o_gpu = assoc_laguerrel( n, m, x);
   }

   if ( !almost_equal(o_host,o_gpu,1) ) {
        std::cerr << "Host: " << o_host << " GPU: " << o_gpu << std::endl;
        throw std::runtime_error( "assoc_laguerrel give incorect value when offloaded");
    }
}

int main()
{
    test_assoc_laguerrel();
}
