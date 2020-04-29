program test_AMIN0
   implicit none
   INTEGER :: in0 = ( 1 )
   INTEGER :: in1 = ( 1 )
   REAL :: o_host, o_device 
    o_host = AMIN0( in0, in1)
    !$OMP target map(from:o_device)
    o_device = AMIN0( in0, in1)
    !$OMP END TARGET
    IF ( ABS(o_host-o_device) > EPSILON(  o_host   )*4 ) THEN
        write(*,*)  'Expected ', o_host, ' Got ', o_device
        CALL EXIT(112)
    ENDIF
end program test_AMIN0
