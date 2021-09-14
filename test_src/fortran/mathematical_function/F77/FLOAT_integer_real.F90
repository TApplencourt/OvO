program test_FLOAT
   implicit none
   INTEGER :: in0 = ( 1 )
   REAL :: o_host, o_device
    o_host = FLOAT( in0)
    !$OMP target map(from:o_device)
    o_device = FLOAT( in0)
    !$OMP END TARGET
    IF ( ABS(o_host-o_device) > EPSILON( o_host )*4 ) THEN
        write(*,*) 'Expected ', o_host, ' Got ', o_device
        STOP 112
    ENDIF
end program test_FLOAT
