program test_LOG
   implicit none
   COMPLEX :: in0 = ( 0.42, 0.0 )
   COMPLEX :: o_host, o_device 
    o_host = LOG( in0)
    !$OMP target map(from:o_device)
    o_device = LOG( in0)
    !$OMP END TARGET
    IF ( ABS(o_host-o_device) > EPSILON(  REAL (  o_host  )   ) ) THEN
        write(*,*)  'Expected ', o_host, ' Got ', o_device
        call exit(1)
    ENDIF
end program test_LOG
