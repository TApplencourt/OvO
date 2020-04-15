program target_teams_distribute__parallel_loop.f90

    

    implicit none

    REAL, ALLOCATABLE :: A(:) 
    REAL, ALLOCATABLE :: B(:)
    

  
    INTEGER :: L = 5
    INTEGER :: i
    INTEGER :: M = 6
    INTEGER :: j

    INTEGER :: S
    S = L*M
     
    ALLOCATE(A(S), B(S)  )
       
    
    CALL RANDOM_NUMBER(B)
    

    
    !$OMP TARGET TEAMS DISTRIBUTE   MAP(FROM: A) MAP(TO: B) 


    DO i = 1 , L 

    
    !$OMP PARALLEL LOOP 


    DO j = 1 , M 

    

    A( j + (i-1)*M ) = B( j + (i-1)*M )
 
     

    END DO

    !$OMP END PARALLEL LOOP
     

    END DO

    !$OMP END TARGET TEAMS DISTRIBUTE
    

    IF (ANY(ABS(A - B) > EPSILON(  B  ) )) THEN
        write(*,*)  'Wrong value', MAXVAL(ABS(A-B)), 'max difference'
        call exit(1)
    ENDIF

    DEALLOCATE(A,B)

end program target_teams_distribute__parallel_loop.f90