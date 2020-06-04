program target_teams_distribute__parallel__do__simd
    implicit none
    DOUBLE COMPLEX, ALLOCATABLE :: A(:) 
    DOUBLE COMPLEX, ALLOCATABLE :: B(:)
    REAL, ALLOCATABLE :: B_real(:)
    REAL, ALLOCATABLE :: B_imag(:)
    INTEGER :: N_i = 64
    INTEGER :: i
    INTEGER :: N_j = 64
    INTEGER :: j
    INTEGER :: N_k = 64
    INTEGER :: k
    INTEGER :: S
    S = N_i*N_j*N_k
    ALLOCATE(A(S), B(S) , B_real(S), B_imag(S)  )
    CALL RANDOM_NUMBER(B_real)
    CALL RANDOM_NUMBER(B_imag)
    B = cmplx(B_real,B_imag)
    DEALLOCATE (B_real,B_imag)
    !$OMP TARGET TEAMS DISTRIBUTE   MAP(FROM: A) MAP(TO: B) 
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
    IF (ANY(ABS(A - B) > EPSILON(  REAL(  B  )  ) )) THEN
        WRITE(*,*)  'Wrong value', MAXVAL(ABS(A-B)), 'max difference'
        CALL EXIT(112)
    ENDIF
    DEALLOCATE(A,B)
end program target_teams_distribute__parallel__do__simd
