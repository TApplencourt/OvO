program target__teams__distribute__simd

    implicit none

    REAL, ALLOCATABLE :: A(:)  
    REAL, ALLOCATABLE :: B(:)
  
    INTEGER :: L = 5
    INTEGER :: i
    INTEGER :: M = 6
    INTEGER :: j

    INTEGER :: S
    S = L*M
     
    ALLOCATE(A(S), B(S) )
    CALL RANDOM_NUMBER(B)
  
    
    !$OMP TARGET   MAP(FROM: A(1:S) ) MAP(TO: B(1:S) ) 


    
    !$OMP TEAMS 


    
    !$OMP DISTRIBUTE 


    DO i = 1 , L 

    
    !$OMP SIMD 


    DO j = 1 , M 

    

    A( j + (i-1)*M ) = B( j + (i-1)*M )
 
     

    END DO

    !$OMP END SIMD
     

    END DO

    !$OMP END DISTRIBUTE
     

    !$OMP END TEAMS
     

    !$OMP END TARGET
    

    IF (ANY(ABS(A - B) > EPSILON(A) )) THEN
        write(*,*)  'Wrong value', MAXVAL(ABS(A-B)), 'max difference'
        call exit(1)
    ENDIF

    DEALLOCATE(A,B)

end program target__teams__distribute__simd