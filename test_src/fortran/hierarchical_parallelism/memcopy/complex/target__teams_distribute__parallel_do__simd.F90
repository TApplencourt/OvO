program target__teams_distribute__parallel_do__simd
    implicit none
    COMPLEX, ALLOCATABLE :: A(:) 
    COMPLEX, ALLOCATABLE :: B(:)
    REAL, ALLOCATABLE :: B_real(:)
    REAL, ALLOCATABLE :: B_imag(:)
    INTEGER :: L = 64
    INTEGER :: i
    INTEGER :: M = 64
    INTEGER :: j
    INTEGER :: N = 64
    INTEGER :: k
    INTEGER :: S
    S = L*M*N
    ALLOCATE(A(S), B(S) , B_real(S), B_imag(S)  )
    CALL RANDOM_NUMBER(B_real)
    CALL RANDOM_NUMBER(B_imag)
    B = cmplx(B_real,B_imag)
    DEALLOCATE (B_real,B_imag)
    !$OMP TARGET   MAP(FROM: A) MAP(TO: B) 
    !$OMP TEAMS DISTRIBUTE 
    DO i = 1 , L 
    !$OMP PARALLEL DO 
    DO j = 1 , M 
    !$OMP SIMD 
    DO k = 1 , N 
    A( k + (j-1)*N + (i-1)*N*M ) = B( k + (j-1)*N + (i-1)*N*M )
    END DO
    !$OMP END SIMD
    END DO
    !$OMP END PARALLEL DO
    END DO
    !$OMP END TEAMS DISTRIBUTE
    !$OMP END TARGET
    IF (ANY(ABS(A - B) > EPSILON(  REAL(  B  )  ) )) THEN
        WRITE(*,*)  'Wrong value', MAXVAL(ABS(A-B)), 'max difference'
        CALL EXIT(112)
    ENDIF
    DEALLOCATE(A,B)
end program target__teams_distribute__parallel_do__simd
