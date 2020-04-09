
program target__teams_distribute_parallel_for
    USE OMP_LIB

    implicit none
  
    INTEGER :: L = 5
    INTEGER :: i
    
    REAL :: COUNTER = 0

    
    

     
    
    !$OMP TARGET   MAP(TOFROM: COUNTER) 



    

    
    !$OMP TEAMS DISTRIBUTE PARALLEL DO 


    DO i = 1 , L 


    

    

!$OMP ATOMIC UPDATE

counter = counter + 1.


 
     

    END DO

    !$OMP END TEAMS DISTRIBUTE PARALLEL DO
     

    !$OMP END TARGET
    

    IF  ( ( ABS(COUNTER - L) ) > 10*EPSILON(COUNTER) ) THEN
        write(*,*)  'Expected L Got', COUNTER
        call exit(1)
    ENDIF

end program target__teams_distribute_parallel_for