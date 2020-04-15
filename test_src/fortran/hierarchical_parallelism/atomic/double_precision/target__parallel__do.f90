

program target__parallel__do.f90


    implicit none
  
    INTEGER :: L = 5
    INTEGER :: i
    
    DOUBLE PRECISION :: COUNTER = 0

    
    

     
    
    !$OMP TARGET   MAP(TOFROM: COUNTER) 



    

    
    !$OMP PARALLEL 



    

    
    !$OMP DO 


    DO i = 1 , L 


    

    

!$OMP ATOMIC UPDATE

counter = counter + 1.


 
     

    END DO

    !$OMP END DO
     

    !$OMP END PARALLEL
     

    !$OMP END TARGET
    

    IF  ( ( ABS(COUNTER - L) ) > 10*EPSILON(COUNTER) ) THEN
        write(*,*)  'Expected L Got', COUNTER
        call exit(1)
    ENDIF

end program target__parallel__do.f90