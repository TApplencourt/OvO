

program target_parallel__loop.f90


    implicit none
  
    INTEGER :: L = 5
    INTEGER :: i
    
    REAL :: COUNTER = 0

    
    

     
    
    !$OMP TARGET PARALLEL   MAP(TOFROM: COUNTER) 



    

    
    !$OMP LOOP 


    DO i = 1 , L 


    

    

!$OMP ATOMIC UPDATE

counter = counter + 1.


 
     

    END DO

    !$OMP END LOOP
     

    !$OMP END TARGET PARALLEL
    

    IF  ( ( ABS(COUNTER - L) ) > 10*EPSILON(COUNTER) ) THEN
        write(*,*)  'Expected L Got', COUNTER
        call exit(1)
    ENDIF

end program target_parallel__loop.f90