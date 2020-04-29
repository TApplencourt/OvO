program target_parallel_do_simd
    implicit none
    DOUBLE PRECISION, ALLOCATABLE :: A(:) 
    DOUBLE PRECISION, ALLOCATABLE :: B(:)
    INTEGER :: L = 262144
    INTEGER :: i
    INTEGER :: S
    S = L
    ALLOCATE(A(S), B(S)  )
    CALL RANDOM_NUMBER(B)
    !$OMP TARGET PARALLEL DO SIMD   MAP(FROM: A) MAP(TO: B) 
    DO i = 1 , L 
    A( i ) = B( i )
    END DO
    !$OMP END TARGET PARALLEL DO SIMD
    IF (ANY(ABS(A - B) > EPSILON(  B  ) )) THEN
        WRITE(*,*)  'Wrong value', MAXVAL(ABS(A-B)), 'max difference'
        CALL EXIT(112)
    ENDIF
    DEALLOCATE(A,B)
end program target_parallel_do_simd
