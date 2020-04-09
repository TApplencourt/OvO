program target_teams__distribute

    implicit none

    REAL, ALLOCATABLE :: A(:)  
    REAL, ALLOCATABLE :: B(:)
  
    INTEGER :: L = 5
    INTEGER :: i

    INTEGER :: S
    S = L
     
    ALLOCATE(A(S), B(S) )
    CALL RANDOM_NUMBER(B)
  
    
    !$OMP TARGET TEAMS   MAP(FROM: A) MAP(TO: B) 


    
    !$OMP DISTRIBUTE 


    DO i = 1 , L 

    

    A( i ) = B( i )
 
     

    END DO

    !$OMP END DISTRIBUTE
     

    !$OMP END TARGET TEAMS
    

    IF (ANY(ABS(A - B) > EPSILON(A) )) THEN
        write(*,*)  'Wrong value', MAXVAL(ABS(A-B)), 'max difference'
        call exit(1)
    ENDIF

    DEALLOCATE(A,B)

end program target_teams__distribute