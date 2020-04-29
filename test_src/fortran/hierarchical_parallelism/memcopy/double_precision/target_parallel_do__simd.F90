program target_parallel_do__simd
    implicit none
    DOUBLE PRECISION, ALLOCATABLE :: A(:) 
    DOUBLE PRECISION, ALLOCATABLE :: B(:)
    INTEGER :: L = 4096
    INTEGER :: i
    INTEGER :: M = 64
    INTEGER :: j
    INTEGER :: S
    S = L*M
    ALLOCATE(A(S), B(S)  )
    CALL RANDOM_NUMBER(B)
    !$OMP TARGET PARALLEL DO   MAP(FROM: A) MAP(TO: B) 
    DO i = 1 , L 
    !$OMP SIMD 
    DO j = 1 , M 
    A( j + (i-1)*M ) = B( j + (i-1)*M )
    END DO
    !$OMP END SIMD
    END DO
    !$OMP END TARGET PARALLEL DO
    IF (ANY(ABS(A - B) > EPSILON(  B  ) )) THEN
        WRITE(*,*)  'Wrong value', MAXVAL(ABS(A-B)), 'max difference'
        CALL EXIT(112)
    ENDIF
    DEALLOCATE(A,B)
end program target_parallel_do__simd
