program target__parallel_for

    implicit none

    REAL, ALLOCATABLE :: A(:)  
    REAL, ALLOCATABLE :: B(:)
  
    INTEGER :: L = 5
    INTEGER :: i

    INTEGER :: S
    S = L
     
    ALLOCATE(A(S), B(S) )
    CALL RANDOM_NUMBER(B)
  
    
    !$OMP TARGET   MAP(FROM: A) MAP(TO: B) 


    
    !$OMP PARALLEL DO 


    DO i = 1 , L 

    

    A( i ) = B( i )
 
     

    END DO

    !$OMP END PARALLEL DO
     

    !$OMP END TARGET
    

    IF (ANY(ABS(A - B) > EPSILON(A) )) THEN
        write(*,*)  'Wrong value', MAXVAL(ABS(A-B)), 'max difference'
        call exit(1)
    ENDIF

    DEALLOCATE(A,B)

end program target__parallel_for