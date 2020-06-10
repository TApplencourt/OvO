program target_teams_distribute__parallel__do__simd
    implicit none
    DOUBLE COMPLEX, ALLOCATABLE :: A(:)
    DOUBLE COMPLEX, ALLOCATABLE :: B(:)
    REAL, ALLOCATABLE :: B_real(:)
    REAL, ALLOCATABLE :: B_imag(:)
    INTEGER :: N0 = 64
    INTEGER :: i0
    INTEGER :: N1 = 64
    INTEGER :: i1
    INTEGER :: N2 = 64
    INTEGER :: i2
    INTEGER :: idx
    INTEGER :: S
    S = N0*N1*N2
    ALLOCATE(A(S), B(S) , B_real(S), B_imag(S)  )
    CALL RANDOM_NUMBER(B_real)
    CALL RANDOM_NUMBER(B_imag)
    B = cmplx(B_real,B_imag)
    DEALLOCATE (B_real,B_imag)
    !$OMP TARGET TEAMS DISTRIBUTE   MAP(FROM: A) MAP(TO: B)
       DO i0 = 1 , N0
    !$OMP PARALLEL
    !$OMP DO
       DO i1 = 1 , N1
    !$OMP SIMD
       DO i2 = 1 , N2
    idx = i2-1+N2*(i1-1+N1*(i0-1))+1
    A( idx ) = B( idx )
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
