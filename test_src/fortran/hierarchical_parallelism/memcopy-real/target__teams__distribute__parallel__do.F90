program target__teams__distribute__parallel__do
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
    !$OMP TEAMS 
    !$OMP DISTRIBUTE 
    DO i = 1 , N_i 
    !$OMP PARALLEL 
    !$OMP DO 
    DO j = 1 , N_j 
    A( (j-1)+(i-1)*N_j+1 ) = B( (j-1)+(i-1)*N_j+1 )
    END DO
!$OMP END PARALLEL
    END DO
!$OMP END TEAMS
!$OMP END TARGET
    IF (ANY(ABS(A - B) > EPSILON(  B  ) )) THEN
        WRITE(*,*)  'Wrong value', MAXVAL(ABS(A-B)), 'max difference'
        CALL EXIT(112)
    ENDIF
    DEALLOCATE(A,B)
end program target__teams__distribute__parallel__do
