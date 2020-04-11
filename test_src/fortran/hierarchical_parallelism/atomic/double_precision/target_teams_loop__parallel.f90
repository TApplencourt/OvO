program target_teams_loop__parallel

    USE OMP_LIB


    implicit none
  
    INTEGER :: L = 5
    INTEGER :: i
    
    DOUBLE PRECISION :: COUNTER = 0

    
    
    INTEGER :: num_threads
    

     
    
    !$OMP TARGET TEAMS LOOP   MAP(TOFROM: COUNTER) 


    DO i = 1 , L 


    

    
    !$OMP PARALLEL 



    
    num_threads = omp_get_num_threads()
    

    

!$OMP ATOMIC UPDATE

counter =  counter +1./num_threads


 
     

    !$OMP END PARALLEL
     

    END DO

    !$OMP END TARGET TEAMS LOOP
    

    IF  ( ( ABS(COUNTER - L) ) > 10*EPSILON(COUNTER) ) THEN
        write(*,*)  'Expected L Got', COUNTER
        call exit(1)
    ENDIF

end program target_teams_loop__parallel