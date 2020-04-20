program target_parallel__loop__simd
    implicit none
    DOUBLE PRECISION, ALLOCATABLE :: A(:) 
    DOUBLE PRECISION, ALLOCATABLE :: B(:)
    INTEGER :: L = 5
    INTEGER :: i
    INTEGER :: M = 6
    INTEGER :: j
    INTEGER :: S
    S = L*M
    ALLOCATE(A(S), B(S)  )
    CALL RANDOM_NUMBER(B)
    !$OMP TARGET PARALLEL   MAP(FROM: A) MAP(TO: B) 
    !$OMP LOOP 
    DO i = 1 , L 
    !$OMP SIMD 
    DO j = 1 , M 
    A( j + (i-1)*M ) = B( j + (i-1)*M )
    END DO
    !$OMP END SIMD
    END DO
    !$OMP END LOOP
    !$OMP END TARGET PARALLEL
    IF (ANY(ABS(A - B) > EPSILON(  B  ) )) THEN
        write(*,*)  'Wrong value', MAXVAL(ABS(A-B)), 'max difference'
        call exit(1)
    ENDIF
    DEALLOCATE(A,B)
end program target_parallel__loop__simd
