program target__parallel_do__simd
    implicit none
    REAL, ALLOCATABLE :: A(:) 
    REAL, ALLOCATABLE :: B(:)
    INTEGER :: L = 5
    INTEGER :: i
    INTEGER :: M = 6
    INTEGER :: j
    INTEGER :: S
    S = L*M
    ALLOCATE(A(S), B(S)  )
    CALL RANDOM_NUMBER(B)
    !$OMP TARGET   MAP(FROM: A) MAP(TO: B) 
    !$OMP PARALLEL DO 
    DO i = 1 , L 
    !$OMP SIMD 
    DO j = 1 , M 
    A( j + (i-1)*M ) = B( j + (i-1)*M )
    END DO
    !$OMP END SIMD
    END DO
    !$OMP END PARALLEL DO
    !$OMP END TARGET
    IF (ANY(ABS(A - B) > EPSILON(  B  ) )) THEN
        write(*,*)  'Wrong value', MAXVAL(ABS(A-B)), 'max difference'
        call exit(1)
    ENDIF
    DEALLOCATE(A,B)
end program target__parallel_do__simd
