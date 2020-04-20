program target_teams_distribute_parallel_do
    implicit none
    DOUBLE COMPLEX, ALLOCATABLE :: A(:) 
    DOUBLE COMPLEX, ALLOCATABLE :: B(:)
    REAL, ALLOCATABLE :: B_real(:)
    REAL, ALLOCATABLE :: B_imag(:)
    INTEGER :: L = 5
    INTEGER :: i
    INTEGER :: S
    S = L
    ALLOCATE(A(S), B(S) , B_real(S), B_imag(S)  )
    CALL RANDOM_NUMBER(B_real)
    CALL RANDOM_NUMBER(B_imag)
    B = cmplx(B_real,B_imag)
    DEALLOCATE (B_real,B_imag)
    !$OMP TARGET TEAMS DISTRIBUTE PARALLEL DO   MAP(FROM: A) MAP(TO: B) 
    DO i = 1 , L 
    A( i ) = B( i )
    END DO
    !$OMP END TARGET TEAMS DISTRIBUTE PARALLEL DO
    IF (ANY(ABS(A - B) > EPSILON(  REAL(  B  )  ) )) THEN
        write(*,*)  'Wrong value', MAXVAL(ABS(A-B)), 'max difference'
        call exit(1)
    ENDIF
    DEALLOCATE(A,B)
end program target_teams_distribute_parallel_do
