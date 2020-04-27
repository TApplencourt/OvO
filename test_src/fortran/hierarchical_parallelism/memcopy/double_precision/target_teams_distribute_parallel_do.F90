program target_teams_distribute_parallel_do
    implicit none
    DOUBLE PRECISION, ALLOCATABLE :: A(:) 
    DOUBLE PRECISION, ALLOCATABLE :: B(:)
    INTEGER :: L = 262144
    INTEGER :: i
    INTEGER :: S
    S = L
    ALLOCATE(A(S), B(S)  )
    CALL RANDOM_NUMBER(B)
    !$OMP TARGET TEAMS DISTRIBUTE PARALLEL DO   MAP(FROM: A) MAP(TO: B) 
    DO i = 1 , L 
    A( i ) = B( i )
    END DO
    !$OMP END TARGET TEAMS DISTRIBUTE PARALLEL DO
    IF (ANY(ABS(A - B) > EPSILON(  B  ) )) THEN
        write(*,*)  'Wrong value', MAXVAL(ABS(A-B)), 'max difference'
        call exit(1)
    ENDIF
    DEALLOCATE(A,B)
end program target_teams_distribute_parallel_do
