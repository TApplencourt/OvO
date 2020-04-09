
program target__teams__loop_distribute__parallel
    USE OMP_LIB

    implicit none
  
    INTEGER :: L = 5
    INTEGER :: i
    
    REAL :: COUNTER = 0

    
    INTEGER :: num_teams
    
    
    INTEGER :: num_threads
    

     
    
    !$OMP TARGET   MAP(TOFROM: COUNTER) 



    

    
    !$OMP TEAMS 



    
    num_teams = omp_get_num_teams()
    

    
    !$OMP LOOP_DISTRIBUTE 


    DO i = 1 , L 


    

    
    !$OMP PARALLEL 



    
    num_threads = omp_get_num_threads()
    

    

!$OMP ATOMIC UPDATE

counter = counter + 1./(num_teams*num_threads)


 
     

    !$OMP END PARALLEL
     

    END DO

    !$OMP END LOOP_DISTRIBUTE
     

    !$OMP END TEAMS
     

    !$OMP END TARGET
    

    IF  ( ( ABS(COUNTER - L) ) > 10*EPSILON(COUNTER) ) THEN
        write(*,*)  'Expected L Got', COUNTER
        call exit(1)
    ENDIF

end program target__teams__loop_distribute__parallel