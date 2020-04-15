program test_INT

   

   implicit none

   
   COMPLEX :: in0 = ( 0.42, 0.0 )
   
 
   INTEGER :: o_host, o_device 

    o_host = INT( in0)

    !$OMP target map(from:o_device)
    o_device = INT( in0)
    !$OMP END TARGET

    
    IF  ( o_host .ne. o_device)  THEN
    
        write(*,*)  'Expected ', o_host, ' Got ', o_device
        call exit(1)
    ENDIF

end program test_INT
