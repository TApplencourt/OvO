

program target__teams_distribute.f90


    

    implicit none
  
    INTEGER :: L = 5
    INTEGER :: i
    
    DOUBLE COMPLEX :: COUNTER =  (    0   ,0)  

    
    
     
    
    !$OMP TARGET    MAP(TOFROM: COUNTER) 



    

    
    !$OMP TEAMS DISTRIBUTE   REDUCTION(+:COUNTER)  


    DO i = 1 , L 


    

    


counter = counter +  CMPLX(   1.  ,0)  

 
     

    END DO

    !$OMP END TEAMS DISTRIBUTE
     

    !$OMP END TARGET
    

    IF  ( ( ABS(COUNTER - L) ) > 10*EPSILON( REAL(  COUNTER  )   ) ) THEN
        write(*,*)  'Expected L Got', COUNTER
        call exit(1)
    ENDIF

end program target__teams_distribute.f90