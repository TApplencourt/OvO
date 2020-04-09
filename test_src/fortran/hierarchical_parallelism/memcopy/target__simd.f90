program target__simd

    implicit none

    REAL, ALLOCATABLE :: A(:)  
    REAL, ALLOCATABLE :: B(:)
  
    INTEGER :: L = 5
    INTEGER :: i

    INTEGER :: S
    S = L
     
    ALLOCATE(A(S), B(S) )
    CALL RANDOM_NUMBER(B)
  
    
    !$OMP TARGET   MAP(FROM: A(1:S) ) MAP(TO: B(1:S) ) 


    
    !$OMP SIMD 


    DO i = 1 , L 

    

    A( i ) = B( i )
 
     

    END DO

    !$OMP END SIMD
     

    !$OMP END TARGET
    

    IF (ANY(ABS(A - B) > EPSILON(A) )) THEN
        write(*,*)  'Wrong value', MAXVAL(ABS(A-B)), 'max difference'
        call exit(1)
    ENDIF

    DEALLOCATE(A,B)

end program target__simd