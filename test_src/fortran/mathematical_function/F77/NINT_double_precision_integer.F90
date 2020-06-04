program test_NINT
   implicit none
   DOUBLE PRECISION :: in0 = ( 0.42 )
   INTEGER :: o_host, o_device 
    o_host = NINT( in0)
    !$OMP target map(from:o_device)
    o_device = NINT( in0)
    !$OMP END TARGET
    IF  ( o_host .ne. o_device)  THEN
        write(*,*)  'Expected ', o_host, ' Got ', o_device
        CALL EXIT(112)
    ENDIF
end program test_NINT
