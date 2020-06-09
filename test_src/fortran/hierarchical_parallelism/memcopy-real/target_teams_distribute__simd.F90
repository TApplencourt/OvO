program target_teams_distribute__simd
    implicit none
    REAL, ALLOCATABLE :: A(:)
    REAL, ALLOCATABLE :: B(:)
    INTEGER :: N0 = 512
    INTEGER :: i0
    INTEGER :: N1 = 512
    INTEGER :: i1
    INTEGER :: idx
    INTEGER :: S
    S = N0*N1
    ALLOCATE(A(S), B(S)  )
    CALL RANDOM_NUMBER(B)
    !$OMP TARGET TEAMS DISTRIBUTE   MAP(FROM: A) MAP(TO: B)
       DO i0 = 1 , N0
    !$OMP SIMD
       DO i0 = 1 , N0
    idx = (i1-1)+((i0-1)*N1)+1
    A( idx ) = B( idx )
    END DO
    END DO
    IF (ANY(ABS(A - B) > EPSILON(  B  ) )) THEN
        WRITE(*,*)  'Wrong value', MAXVAL(ABS(A-B)), 'max difference'
        CALL EXIT(112)
    ENDIF
    DEALLOCATE(A,B)
end program target_teams_distribute__simd
