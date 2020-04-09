program target_parallel__for

    implicit none

    REAL, ALLOCATABLE :: A(:)  
    REAL, ALLOCATABLE :: B(:)
  
    INTEGER :: L = 5
    INTEGER :: i

    INTEGER :: S
    S = L
     
    ALLOCATE(A(S), B(S) )
    CALL RANDOM_NUMBER(B)
  
    
    !$OMP TARGET PARALLEL   MAP(FROM: A(1:S) ) MAP(TO: B(1:S) ) 


    
    !$OMP DO 


    DO i = 1 , L 

    

    A( i ) = B( i )
 
     

    END DO

    !$OMP END DO
     

    !$OMP END TARGET PARALLEL
    

    IF (ANY(ABS(A - B) > EPSILON(A) )) THEN
        write(*,*)  'Wrong value', MAXVAL(ABS(A-B)), 'max difference'
        call exit(1)
    ENDIF

    DEALLOCATE(A,B)

end program target_parallel__for