#include <complex>
#include <iomanip>      // std::setprecision
#include <iostream>     // std::cerr
#include <limits>

bool almost_equal(std::complex<float> x, std::complex<float> y, int ulp) {
    return std::abs(x-y) <= std::numeric_limits<float>::epsilon() * std::abs(x+y) * ulp ||  std::abs(x-y) < std::numeric_limits<float>::min();
}

int main()
{
  std::complex<float> o_host(0.2, 1), o_device;
  #pragma omp target map(from:a_check)
  {
    o_device = o_host;
  }

  if ( !almost_equal(o_host,o_device, 4) ) {
      std::cerr << std::setprecision (std::numeric_limits<float>::max_digits10 ) << "Host: " << o_host << " GPU: " << o_device << std::endl;
      std::exit(112);
  }

}

