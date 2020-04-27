program target__teams_loop__parallel_do__simd
    implicit none
    DOUBLE PRECISION, ALLOCATABLE :: A(:) 
    DOUBLE PRECISION, ALLOCATABLE :: B(:)
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
    !$OMP TEAMS LOOP 
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
    !$OMP END TEAMS LOOP
    !$OMP END TARGET
    IF (ANY(ABS(A - B) > EPSILON(  B  ) )) THEN
        write(*,*)  'Wrong value', MAXVAL(ABS(A-B)), 'max difference'
        call exit(1)
    ENDIF
    DEALLOCATE(A,B)
end program target__teams_loop__parallel_do__simd
