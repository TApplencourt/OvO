program target__teams_distribute__simd
    implicit none
    REAL, ALLOCATABLE :: A(:) 
    REAL, ALLOCATABLE :: B(:)
    INTEGER :: N_i = 64
    INTEGER :: i
    INTEGER :: N_j = 64
    INTEGER :: j
    INTEGER :: S
    S = N_i*N_j
    ALLOCATE(A(S), B(S)  )
    CALL RANDOM_NUMBER(B)
    !$OMP TARGET   MAP(FROM: A) MAP(TO: B) 
    !$OMP TEAMS DISTRIBUTE 
    DO i = 1 , N_i 
    !$OMP SIMD 
    DO j = 1 , N_j 
    A( (j-1)+(i-1)*N_j+1 ) = B( (j-1)+(i-1)*N_j+1 )
    END DO
    END DO
!$OMP END TARGET
    IF (ANY(ABS(A - B) > EPSILON(  B  ) )) THEN
        WRITE(*,*)  'Wrong value', MAXVAL(ABS(A-B)), 'max difference'
        CALL EXIT(112)
    ENDIF
    DEALLOCATE(A,B)
end program target__teams_distribute__simd