program test_DBLE
   implicit none
   COMPLEX :: in0 = ( 0.42, 0.0 )
   DOUBLE PRECISION :: o_host, o_device 
    o_host = DBLE( in0)
    !$OMP target map(from:o_device)
    o_device = DBLE( in0)
    !$OMP END TARGET
    IF ( ABS(o_host-o_device) > EPSILON(  o_host   ) ) THEN
        write(*,*)  'Expected ', o_host, ' Got ', o_device
        call exit(1)
    ENDIF
end program test_DBLE
