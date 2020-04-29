program target__teams__loop__parallel__do__simd
    implicit none
    REAL, ALLOCATABLE :: A(:) 
    REAL, ALLOCATABLE :: B(:)
    INTEGER :: L = 64
    INTEGER :: i
    INTEGER :: M = 64
    INTEGER :: j
    INTEGER :: N = 64
    INTEGER :: k
    INTEGER :: S
    S = L*M*N
    ALLOCATE(A(S), B(S)  )
    CALL RANDOM_NUMBER(B)
    !$OMP TARGET   MAP(FROM: A) MAP(TO: B) 
    !$OMP TEAMS 
    !$OMP LOOP 
    DO i = 1 , L 
    !$OMP PARALLEL 
    !$OMP DO 
    DO j = 1 , M 
    !$OMP SIMD 
    DO k = 1 , N 
    A( k + (j-1)*N + (i-1)*N*M ) = B( k + (j-1)*N + (i-1)*N*M )
    END DO
    !$OMP END SIMD
    END DO
    !$OMP END DO
    !$OMP END PARALLEL
    END DO
    !$OMP END LOOP
    !$OMP END TEAMS
    !$OMP END TARGET
    IF (ANY(ABS(A - B) > EPSILON(  B  ) )) THEN
        WRITE(*,*)  'Wrong value', MAXVAL(ABS(A-B)), 'max difference'
        CALL EXIT(112)
    ENDIF
    DEALLOCATE(A,B)
end program target__teams__loop__parallel__do__simd
