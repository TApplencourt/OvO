

program target_teams_distribute_parallel_do_simd.f90


    

    implicit none
  
    INTEGER :: L = 5
    INTEGER :: i
    
    REAL :: COUNTER =  0   

    
    
     
    
    !$OMP TARGET TEAMS DISTRIBUTE PARALLEL DO SIMD   REDUCTION(+:COUNTER)   MAP(TOFROM: COUNTER) 


    DO i = 1 , L 


    

    


counter = counter +  1.  

 
     

    END DO

    !$OMP END TARGET TEAMS DISTRIBUTE PARALLEL DO SIMD
    

    IF  ( ( ABS(COUNTER - L) ) > 10*EPSILON( COUNTER   ) ) THEN
        write(*,*)  'Expected L Got', COUNTER
        call exit(1)
    ENDIF

end program target_teams_distribute_parallel_do_simd.f90