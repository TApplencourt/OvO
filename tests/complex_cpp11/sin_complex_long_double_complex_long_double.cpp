
#include <complex>


#include <limits>
#include <iostream>
#include <stdexcept>

using namespace std;

bool almost_equal(complex<long double> x, complex<long double> y, int ulp) {

    bool r = std::fabs(x.real()-y.real()) <= std::numeric_limits<long double>::epsilon() * std::fabs(x.real()+y.real()) * ulp ||  std::fabs(x.real()-y.real()) < std::numeric_limits<long double>::min();
    bool i = std::fabs(x.imag()-y.imag()) <= std::numeric_limits<long double>::epsilon() * std::fabs(x.imag()+y.imag()) * ulp ||  std::fabs(x.imag()-y.imag()) < std::numeric_limits<long double>::min();
    return r && i;

}

void test_sin(){
   
   complex<long double> x {  0.42, 0.0 };
   

   complex<long double> o_host = sin( x);

   complex<long double> o_gpu ; 
   #pragma omp target defaultmap(tofrom:scalar)
   {
   o_gpu = sin( x);
   }

   if ( !almost_equal(o_host,o_gpu,1) ) {
        std::cerr << "Host: " << o_host << " GPU: " << o_gpu << std::endl;
        throw std::runtime_error( "sin give incorect value when offloaded");
    }
}

int main()
{
    test_sin();
}
