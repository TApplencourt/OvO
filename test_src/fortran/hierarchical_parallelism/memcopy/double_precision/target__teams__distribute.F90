program target__teams__distribute
    implicit none
    DOUBLE PRECISION, ALLOCATABLE :: A(:) 
    DOUBLE PRECISION, ALLOCATABLE :: B(:)
    INTEGER :: L = 5
    INTEGER :: i
    INTEGER :: S
    S = L
    ALLOCATE(A(S), B(S)  )
    CALL RANDOM_NUMBER(B)
    !$OMP TARGET   MAP(FROM: A) MAP(TO: B) 
    !$OMP TEAMS 
    !$OMP DISTRIBUTE 
    DO i = 1 , L 
    A( i ) = B( i )
    END DO
    !$OMP END DISTRIBUTE
    !$OMP END TEAMS
    !$OMP END TARGET
    IF (ANY(ABS(A - B) > EPSILON(  B  ) )) THEN
        write(*,*)  'Wrong value', MAXVAL(ABS(A-B)), 'max difference'
        call exit(1)
    ENDIF
    DEALLOCATE(A,B)
end program target__teams__distribute
