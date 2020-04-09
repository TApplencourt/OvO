program target_teams_distribute_parallel_for

    implicit none

    REAL, ALLOCATABLE :: A(:)  
    REAL, ALLOCATABLE :: B(:)
  
    INTEGER :: L = 5
    INTEGER :: i

    INTEGER :: S
    S = L
     
    ALLOCATE(A(S), B(S) )
    CALL RANDOM_NUMBER(B)
  
    
    !$OMP TARGET TEAMS DISTRIBUTE PARALLEL DO   MAP(FROM: A(1:S) ) MAP(TO: B(1:S) ) 


    DO i = 1 , L 

    

    A( i ) = B( i )
 
     

    END DO

    !$OMP END TARGET TEAMS DISTRIBUTE PARALLEL DO
    

    IF (ANY(ABS(A - B) > EPSILON(A) )) THEN
        write(*,*)  'Wrong value', MAXVAL(ABS(A-B)), 'max difference'
        call exit(1)
    ENDIF

    DEALLOCATE(A,B)

end program target_teams_distribute_parallel_for