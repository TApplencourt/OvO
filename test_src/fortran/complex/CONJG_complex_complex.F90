program test_CONJG
   implicit none
   COMPLEX :: in0 = ( 0.42, 0.0 )
   COMPLEX :: o_host, o_device 
    o_host = CONJG( in0)
    !$OMP target map(from:o_device)
    o_device = CONJG( in0)
    !$OMP END TARGET
    IF ( ABS(o_host-o_device) > EPSILON(  REAL (  o_host  )   ) ) THEN
        write(*,*)  'Expected ', o_host, ' Got ', o_device
        call exit(1)
    ENDIF
end program test_CONJG
