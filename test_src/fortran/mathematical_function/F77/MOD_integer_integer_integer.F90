program test_MOD
   implicit none
   INTEGER :: in0 = ( 1 )
   INTEGER :: in1 = ( 1 )
   INTEGER :: o_host, o_device 
    o_host = MOD( in0, in1)
    !$OMP target map(from:o_device)
    o_device = MOD( in0, in1)
    !$OMP END TARGET
    IF  ( o_host .ne. o_device)  THEN
        write(*,*)  'Expected ', o_host, ' Got ', o_device
        CALL EXIT(112)
    ENDIF
end program test_MOD
