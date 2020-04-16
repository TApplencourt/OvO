

program target_teams_distribute__simd


    

    implicit none
  
    INTEGER :: L = 5
    INTEGER :: i
    INTEGER :: M = 6
    INTEGER :: j
    
    DOUBLE PRECISION :: COUNTER =  0   

    
    
     
    
    !$OMP TARGET TEAMS DISTRIBUTE   REDUCTION(+:COUNTER)   MAP(TOFROM: COUNTER) 


    DO i = 1 , L 


    

    
    !$OMP SIMD   REDUCTION(+:COUNTER)  


    DO j = 1 , M 


    

    


counter = counter +  1.  

 
     

    END DO

    !$OMP END SIMD
     

    END DO

    !$OMP END TARGET TEAMS DISTRIBUTE
    

    IF  ( ( ABS(COUNTER - L*M) ) > 10*EPSILON( COUNTER   ) ) THEN
        write(*,*)  'Expected L*M Got', COUNTER
        call exit(1)
    ENDIF

end program target_teams_distribute__simd