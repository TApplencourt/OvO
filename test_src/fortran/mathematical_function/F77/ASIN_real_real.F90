program test_ASIN
   implicit none
   REAL :: in0 = ( 0.42 )
   REAL :: o_host, o_device
    !$OMP target map(from:o_device)
    o_device = ASIN( in0)
    !$OMP END TARGET
    IF ( ABS(SIN(o_device) - in0) > EPSILON( in0 )*16 ) THEN
            write(*,*) 'Expected ', in0, ' Got ', SIN(o_device)
            STOP 112
    ENDIF
end program test_ASIN
