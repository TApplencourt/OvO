program target_teams__distribute__parallel__do__simd
    implicit none
    REAL, ALLOCATABLE :: A(:) 
    REAL, ALLOCATABLE :: B(:)
    INTEGER :: N_i = 64
    INTEGER :: i
    INTEGER :: N_j = 64
    INTEGER :: j
    INTEGER :: N_k = 64
    INTEGER :: k
    INTEGER :: S
    S = N_i*N_j*N_k
    ALLOCATE(A(S), B(S)  )
    CALL RANDOM_NUMBER(B)
    !$OMP TARGET TEAMS   MAP(FROM: A) MAP(TO: B) 
    !$OMP DISTRIBUTE 
    DO i = 1 , N_i 
    !$OMP PARALLEL 
    !$OMP DO 
    DO j = 1 , N_j 
    !$OMP SIMD 
    DO k = 1 , N_k 
    A( (k-1)+(j-1)*N_k+(i-1)*N_j*N_k+1 ) = B( (k-1)+(j-1)*N_k+(i-1)*N_j*N_k+1 )
    END DO
    END DO
!$OMP END PARALLEL
    END DO
!$OMP END TARGET TEAMS
    IF (ANY(ABS(A - B) > EPSILON(  B  ) )) THEN
        WRITE(*,*)  'Wrong value', MAXVAL(ABS(A-B)), 'max difference'
        CALL EXIT(112)
    ENDIF
    DEALLOCATE(A,B)
end program target_teams__distribute__parallel__do__simd
