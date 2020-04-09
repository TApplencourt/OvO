
program target__teams__parallel__for
    USE OMP_LIB

    implicit none
  
    INTEGER :: L = 5
    INTEGER :: i
    
    REAL :: COUNTER = 0

    
    INTEGER :: num_teams
    
    

     
    
    !$OMP TARGET   MAP(TOFROM: COUNTER) 



    

    
    !$OMP TEAMS 



    
    num_teams = omp_get_num_teams()
    

    
    !$OMP PARALLEL 



    

    
    !$OMP DO 


    DO i = 1 , L 


    

    

!$OMP ATOMIC UPDATE

counter = counter + 1./num_teams


 
     

    END DO

    !$OMP END DO
     

    !$OMP END PARALLEL
     

    !$OMP END TEAMS
     

    !$OMP END TARGET
    

    IF  ( ( ABS(COUNTER - L) ) > 10*EPSILON(COUNTER) ) THEN
        write(*,*)  'Expected L Got', COUNTER
        call exit(1)
    ENDIF

end program target__teams__parallel__for