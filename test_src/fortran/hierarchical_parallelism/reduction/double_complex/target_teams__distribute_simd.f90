

program target_teams__distribute_simd.f90


    

    implicit none
  
    INTEGER :: L = 5
    INTEGER :: i
    
    DOUBLE COMPLEX :: COUNTER =  (    0   ,0)  

    
    
     
    
    !$OMP TARGET TEAMS   REDUCTION(+:COUNTER)   MAP(TOFROM: COUNTER) 



    

    
    !$OMP DISTRIBUTE SIMD   REDUCTION(+:COUNTER)  


    DO i = 1 , L 


    

    


counter = counter +  CMPLX(   1.  ,0)  

 
     

    END DO

    !$OMP END DISTRIBUTE SIMD
     

    !$OMP END TARGET TEAMS
    

    IF  ( ( ABS(COUNTER - L) ) > 10*EPSILON( REAL(  COUNTER  )   ) ) THEN
        write(*,*)  'Expected L Got', COUNTER
        call exit(1)
    ENDIF

end program target_teams__distribute_simd.f90