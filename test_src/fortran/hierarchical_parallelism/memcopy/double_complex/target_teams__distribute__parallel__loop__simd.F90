program target_teams__distribute__parallel__loop__simd
    implicit none
    DOUBLE COMPLEX, ALLOCATABLE :: A(:) 
    DOUBLE COMPLEX, ALLOCATABLE :: B(:)
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
    !$OMP TARGET TEAMS   MAP(FROM: A) MAP(TO: B) 
    !$OMP DISTRIBUTE 
    DO i = 1 , L 
    !$OMP PARALLEL 
    !$OMP LOOP 
    DO j = 1 , M 
    !$OMP SIMD 
    DO k = 1 , N 
    A( k + (j-1)*N + (i-1)*N*M ) = B( k + (j-1)*N + (i-1)*N*M )
    END DO
    !$OMP END SIMD
    END DO
    !$OMP END LOOP
    !$OMP END PARALLEL
    END DO
    !$OMP END DISTRIBUTE
    !$OMP END TARGET TEAMS
    IF (ANY(ABS(A - B) > EPSILON(  REAL(  B  )  ) )) THEN
        write(*,*)  'Wrong value', MAXVAL(ABS(A-B)), 'max difference'
        call exit(1)
    ENDIF
    DEALLOCATE(A,B)
end program target_teams__distribute__parallel__loop__simd
