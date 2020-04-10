program target__teams_distribute_parallel_do_simd

    

    implicit none

    COMPLEX, ALLOCATABLE :: A(:) 
    COMPLEX, ALLOCATABLE :: B(:)
    
    REAL, ALLOCATABLE :: B_real(:)
    REAL, ALLOCATABLE :: B_imag(:)
    

  
    INTEGER :: L = 5
    INTEGER :: i

    INTEGER :: S
    S = L
     
    ALLOCATE(A(S), B(S) , B_real(S), B_imag(S)  )
       
    
    CALL RANDOM_NUMBER(B_real)
    CALL RANDOM_NUMBER(B_imag)
    B = cmplx(B_real,B_imag)
    DEALLOCATE (B_real,B_imag)
    

    
    !$OMP TARGET   MAP(FROM: A) MAP(TO: B) 


    
    !$OMP TEAMS DISTRIBUTE PARALLEL DO SIMD 


    DO i = 1 , L 

    

    A( i ) = B( i )
 
     

    END DO

    !$OMP END TEAMS DISTRIBUTE PARALLEL DO SIMD
     

    !$OMP END TARGET
    

    IF (ANY(ABS(A - B) > EPSILON(  REAL(  B  )  ) )) THEN
        write(*,*)  'Wrong value', MAXVAL(ABS(A-B)), 'max difference'
        call exit(1)
    ENDIF

    DEALLOCATE(A,B)

end program target__teams_distribute_parallel_do_simd