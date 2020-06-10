program target__teams__distribute
    implicit none
    REAL, ALLOCATABLE :: A(:)
    REAL, ALLOCATABLE :: B(:)
    INTEGER :: N0 = 262144
    INTEGER :: i0
    INTEGER :: idx
    INTEGER :: S
    S = N0
    ALLOCATE(A(S), B(S)  )
    CALL RANDOM_NUMBER(B)
    !$OMP TARGET   MAP(FROM: A) MAP(TO: B)
    !$OMP TEAMS
    !$OMP DISTRIBUTE
       DO i0 = 1 , N0
    idx = i0-1+1
    A( idx ) = B( idx )
    END DO
!$OMP END TEAMS
!$OMP END TARGET
    IF (ANY(ABS(A - B) > EPSILON(  B  ) )) THEN
        WRITE(*,*)  'Wrong value', MAXVAL(ABS(A-B)), 'max difference'
        CALL EXIT(112)
    ENDIF
    DEALLOCATE(A,B)
end program target__teams__distribute
