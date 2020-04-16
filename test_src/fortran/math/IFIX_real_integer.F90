program test_IFIX

   

   implicit none

   
   REAL :: in0 = ( 0.42 )
   
 
   INTEGER :: o_host, o_device 

    o_host = IFIX( in0)

    !$OMP target map(from:o_device)
    o_device = IFIX( in0)
    !$OMP END TARGET

    
    IF  ( o_host .ne. o_device)  THEN
    
        write(*,*)  'Expected ', o_host, ' Got ', o_device
        call exit(1)
    ENDIF

end program test_IFIX
