program test_MAX1
   implicit none
   REAL :: in0 = ( 0.42 )
   REAL :: in1 = ( 0.42 )
   INTEGER :: o_host, o_device
    o_host = MAX1( in0, in1)
    !$OMP target map(from:o_device)
    o_device = MAX1( in0, in1)
    !$OMP END TARGET
    IF  (  o_host .ne. o_device  ) THEN
        write(*,*)  'Expected ', o_host, ' Got ', o_device
        STOP 112
    ENDIF
end program test_MAX1
