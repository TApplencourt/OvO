program target__parallel__do__simd
    implicit none
    DOUBLE COMPLEX, ALLOCATABLE :: A(:) 
    DOUBLE COMPLEX, ALLOCATABLE :: B(:)
    REAL, ALLOCATABLE :: B_real(:)
    REAL, ALLOCATABLE :: B_imag(:)
    INTEGER :: N_i = 64
    INTEGER :: i
    INTEGER :: N_j = 64
    INTEGER :: j
    INTEGER :: S
    S = N_i*N_j
    ALLOCATE(A(S), B(S) , B_real(S), B_imag(S)  )
    CALL RANDOM_NUMBER(B_real)
    CALL RANDOM_NUMBER(B_imag)
    B = cmplx(B_real,B_imag)
    DEALLOCATE (B_real,B_imag)
    !$OMP TARGET   MAP(FROM: A) MAP(TO: B) 
    !$OMP PARALLEL 
    !$OMP DO 
    DO i = 1 , N_i 
    !$OMP SIMD 
    DO j = 1 , N_j 
    A( (j-1)+(i-1)*N_j+1 ) = B( (j-1)+(i-1)*N_j+1 )
    END DO
    END DO
!$OMP END PARALLEL
!$OMP END TARGET
    IF (ANY(ABS(A - B) > EPSILON(  REAL(  B  )  ) )) THEN
        WRITE(*,*)  'Wrong value', MAXVAL(ABS(A-B)), 'max difference'
        CALL EXIT(112)
    ENDIF
    DEALLOCATE(A,B)
end program target__parallel__do__simd
