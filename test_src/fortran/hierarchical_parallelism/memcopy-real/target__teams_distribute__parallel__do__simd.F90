PROGRAM target__teams_distribute__parallel__do__simd
  implicit none
  INTEGER :: N0 = 32
  INTEGER :: i0
  INTEGER :: N1 = 32
  INTEGER :: i1
  INTEGER :: N2 = 32
  INTEGER :: i2
  INTEGER :: idx, S
  INTEGER :: errno = 0
  REAL, ALLOCATABLE :: src(:)
  REAL, ALLOCATABLE :: dst(:)
  S = N0*N1*N2
  ALLOCATE(dst(S), src(S) )
  CALL RANDOM_NUMBER(src)
  !$OMP TARGET map(to: src) map(from: dst) private(idx)
  !$OMP TEAMS DISTRIBUTE private(idx)
  DO i0 = 1, N0
    !$OMP PARALLEL private(idx)
    !$OMP DO
    DO i1 = 1, N1
      !$OMP SIMD private(idx)
      DO i2 = 1, N2
        idx = i2-1+N2*(i1-1+N1*(i0-1))+1
        dst(idx) = src(idx)
      END DO
    END DO
    !$OMP END PARALLEL
  END DO
  !$OMP END TARGET
  IF (ANY(ABS(dst - src) > EPSILON(src))) THEN
    WRITE(*,*) 'Wrong value', MAXVAL(ABS(DST-SRC)), 'max difference'
    errno = 112
  ENDIF
  DEALLOCATE(src, dst)
  IF (errno .EQ. 112) STOP 112
END PROGRAM target__teams_distribute__parallel__do__simd
