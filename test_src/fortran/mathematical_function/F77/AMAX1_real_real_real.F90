program test_AMAX1
   implicit none
   REAL :: in0 = ( 0.42 )
   REAL :: in1 = ( 0.42 )
   REAL :: o_host, o_device 
    o_host = AMAX1( in0, in1)
    !$OMP target map(from:o_device)
    o_device = AMAX1( in0, in1)
    !$OMP END TARGET
    IF ( ABS(o_host-o_device) > EPSILON(  o_host   )*4 ) THEN
        write(*,*)  'Expected ', o_host, ' Got ', o_device
        CALL EXIT(112)
    ENDIF
end program test_AMAX1
