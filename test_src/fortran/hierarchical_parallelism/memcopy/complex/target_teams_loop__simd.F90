program target_teams_loop__simd
    implicit none
    COMPLEX, ALLOCATABLE :: A(:) 
    COMPLEX, ALLOCATABLE :: B(:)
    REAL, ALLOCATABLE :: B_real(:)
    REAL, ALLOCATABLE :: B_imag(:)
    INTEGER :: L = 4096
    INTEGER :: i
    INTEGER :: M = 64
    INTEGER :: j
    INTEGER :: S
    S = L*M
    ALLOCATE(A(S), B(S) , B_real(S), B_imag(S)  )
    CALL RANDOM_NUMBER(B_real)
    CALL RANDOM_NUMBER(B_imag)
    B = cmplx(B_real,B_imag)
    DEALLOCATE (B_real,B_imag)
    !$OMP TARGET TEAMS LOOP   MAP(FROM: A) MAP(TO: B) 
    DO i = 1 , L 
    !$OMP SIMD 
    DO j = 1 , M 
    A( j + (i-1)*M ) = B( j + (i-1)*M )
    END DO
    !$OMP END SIMD
    END DO
    !$OMP END TARGET TEAMS LOOP
    IF (ANY(ABS(A - B) > EPSILON(  REAL(  B  )  ) )) THEN
        write(*,*)  'Wrong value', MAXVAL(ABS(A-B)), 'max difference'
        call exit(1)
    ENDIF
    DEALLOCATE(A,B)
end program target_teams_loop__simd
