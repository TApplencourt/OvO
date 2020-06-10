program target__teams_distribute__parallel_do__simd
    implicit none
    REAL, ALLOCATABLE :: A(:)
    REAL, ALLOCATABLE :: B(:)
    INTEGER :: N0 = 64
    INTEGER :: i0
    INTEGER :: N1 = 64
    INTEGER :: i1
    INTEGER :: N2 = 64
    INTEGER :: i2
    INTEGER :: idx
    INTEGER :: S
    S = N0*N1*N2
    ALLOCATE(A(S), B(S)  )
    CALL RANDOM_NUMBER(B)
    !$OMP TARGET   MAP(FROM: A) MAP(TO: B)
    !$OMP TEAMS DISTRIBUTE
       DO i0 = 1 , N0
    !$OMP PARALLEL DO
       DO i1 = 1 , N1
    !$OMP SIMD
       DO i2 = 1 , N2
    idx = i2-1+N2*(i1-1+N1*(i0-1))+1
    A( idx ) = B( idx )
    END DO
    END DO
    END DO
!$OMP END TARGET
    IF (ANY(ABS(A - B) > EPSILON(  B  ) )) THEN
        WRITE(*,*)  'Wrong value', MAXVAL(ABS(A-B)), 'max difference'
        CALL EXIT(112)
    ENDIF
    DEALLOCATE(A,B)
end program target__teams_distribute__parallel_do__simd
