program target_teams_distribute
    implicit none
    DOUBLE COMPLEX, ALLOCATABLE :: A(:)
    DOUBLE COMPLEX, ALLOCATABLE :: B(:)
    REAL, ALLOCATABLE :: B_real(:)
    REAL, ALLOCATABLE :: B_imag(:)
    INTEGER :: N0 = 262144
    INTEGER :: i0
    INTEGER :: idx
    INTEGER :: S
    S = N0
    ALLOCATE(A(S), B(S) , B_real(S), B_imag(S)  )
    CALL RANDOM_NUMBER(B_real)
    CALL RANDOM_NUMBER(B_imag)
    B = cmplx(B_real,B_imag)
    DEALLOCATE (B_real,B_imag)
    !$OMP TARGET TEAMS DISTRIBUTE   MAP(FROM: A) MAP(TO: B)
       DO i0 = 1 , N0
    idx = (i0-1)+1
    A( idx ) = B( idx )
    END DO
    IF (ANY(ABS(A - B) > EPSILON(  REAL(  B  )  ) )) THEN
        WRITE(*,*)  'Wrong value', MAXVAL(ABS(A-B)), 'max difference'
        CALL EXIT(112)
    ENDIF
    DEALLOCATE(A,B)
end program target_teams_distribute
