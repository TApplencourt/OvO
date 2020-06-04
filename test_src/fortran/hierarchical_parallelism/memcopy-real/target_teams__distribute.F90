program target_teams__distribute
    implicit none
    REAL, ALLOCATABLE :: A(:) 
    REAL, ALLOCATABLE :: B(:)
    INTEGER :: N_i = 64
    INTEGER :: i
    INTEGER :: S
    S = N_i
    ALLOCATE(A(S), B(S)  )
    CALL RANDOM_NUMBER(B)
    !$OMP TARGET TEAMS   MAP(FROM: A) MAP(TO: B) 
    !$OMP DISTRIBUTE 
    DO i = 1 , N_i 
    A( (i-1)+1 ) = B( (i-1)+1 )
    END DO
!$OMP END TARGET TEAMS
    IF (ANY(ABS(A - B) > EPSILON(  B  ) )) THEN
        WRITE(*,*)  'Wrong value', MAXVAL(ABS(A-B)), 'max difference'
        CALL EXIT(112)
    ENDIF
    DEALLOCATE(A,B)
end program target_teams__distribute