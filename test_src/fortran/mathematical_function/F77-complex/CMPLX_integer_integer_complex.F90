program test_CMPLX
   implicit none
   INTEGER :: in0 = ( 1 )
   INTEGER :: in1 = ( 1 )
   COMPLEX :: o_host, o_device
    o_host = CMPLX( in0, in1)
    !$OMP target map(from:o_device)
    o_device = CMPLX( in0, in1)
    !$OMP END TARGET
    IF ( ABS(o_host-o_device) > EPSILON(  REAL (  o_host  )   )*4 ) THEN
        write(*,*)  'Expected ', o_host, ' Got ', o_device
        CALL EXIT(112)
    ENDIF
end program test_CMPLX
