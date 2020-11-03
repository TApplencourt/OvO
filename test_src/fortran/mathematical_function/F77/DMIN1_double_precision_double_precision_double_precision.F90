program test_DMIN1
   implicit none
   DOUBLE PRECISION :: in0 = ( 0.42 )
   DOUBLE PRECISION :: in1 = ( 0.42 )
   DOUBLE PRECISION :: o_host, o_device
    o_host = DMIN1( in0, in1)
    !$OMP target map(from:o_device)
    o_device = DMIN1( in0, in1)
    !$OMP END TARGET
    IF (  ABS(o_host-o_device) > EPSILON(  o_host   )*4   ) THEN
        write(*,*)  'Expected ', o_host, ' Got ', o_device
        STOP 112
    ENDIF
end program test_DMIN1
