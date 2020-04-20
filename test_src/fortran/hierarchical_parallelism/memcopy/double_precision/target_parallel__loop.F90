program target_parallel__loop
    implicit none
    DOUBLE PRECISION, ALLOCATABLE :: A(:) 
    DOUBLE PRECISION, ALLOCATABLE :: B(:)
    INTEGER :: L = 5
    INTEGER :: i
    INTEGER :: S
    S = L
    ALLOCATE(A(S), B(S)  )
    CALL RANDOM_NUMBER(B)
    !$OMP TARGET PARALLEL   MAP(FROM: A) MAP(TO: B) 
    !$OMP LOOP 
    DO i = 1 , L 
    A( i ) = B( i )
    END DO
    !$OMP END LOOP
    !$OMP END TARGET PARALLEL
    IF (ANY(ABS(A - B) > EPSILON(  B  ) )) THEN
        write(*,*)  'Wrong value', MAXVAL(ABS(A-B)), 'max difference'
        call exit(1)
    ENDIF
    DEALLOCATE(A,B)
end program target_parallel__loop
