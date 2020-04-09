
program target_teams_distribute__parallel__loop_for
    USE OMP_LIB

    implicit none
  
    INTEGER :: L = 5
    INTEGER :: i
    INTEGER :: M = 6
    INTEGER :: j
    
    REAL :: COUNTER = 0

    
    
    INTEGER :: num_threads
    
     
    
    !$OMP TARGET TEAMS DISTRIBUTE   REDUCTION(+:COUNTER)   MAP(TOFROM: COUNTER) 


    DO i = 1 , L 


    

    
    !$OMP PARALLEL   REDUCTION(+:COUNTER)  



    
    num_threads = omp_get_num_threads()
    

    
    !$OMP LOOP_DO   REDUCTION(+:COUNTER)  


    DO j = 1 , M 


    

    


counter =  counter +1./num_threads

 
     

    END DO

    !$OMP END LOOP_DO
     

    !$OMP END PARALLEL
     

    END DO

    !$OMP END TARGET TEAMS DISTRIBUTE
    

    IF  ( ( ABS(COUNTER - L*M) ) > 10*EPSILON(COUNTER) ) THEN
        write(*,*)  'Expected L*M Got', COUNTER
        call exit(1)
    ENDIF

end program target_teams_distribute__parallel__loop_for