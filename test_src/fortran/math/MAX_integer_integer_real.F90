program test_MAX
   implicit none
   INTEGER :: in0 = ( 1 )
   INTEGER :: in1 = ( 1 )
   REAL :: o_host, o_device 
    o_host = MAX( in0, in1)
    !$OMP target map(from:o_device)
    o_device = MAX( in0, in1)
    !$OMP END TARGET
    IF ( ABS(o_host-o_device) > EPSILON(  o_host   ) ) THEN
        write(*,*)  'Expected ', o_host, ' Got ', o_device
        call exit(1)
    ENDIF
end program test_MAX
