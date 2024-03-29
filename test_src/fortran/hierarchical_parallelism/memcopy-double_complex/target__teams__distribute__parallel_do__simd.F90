PROGRAM target__teams__distribute__parallel_do__simd
  implicit none
  INTEGER :: N0 = 32
  INTEGER :: i0
  INTEGER :: N1 = 32
  INTEGER :: i1
  INTEGER :: N2 = 32
  INTEGER :: i2
  INTEGER :: idx, S
  INTEGER :: errno = 0
  DOUBLE COMPLEX, ALLOCATABLE :: src(:)
  DOUBLE COMPLEX, ALLOCATABLE :: dst(:)
  REAL, ALLOCATABLE :: src_real(:)
  REAL, ALLOCATABLE :: src_imag(:)
  S = N0*N1*N2
  ALLOCATE(dst(S), src(S) )
  ALLOCATE(src_real(S),src_imag(S))
  CALL RANDOM_NUMBER(src_real)
  CALL RANDOM_NUMBER(src_imag)
  src = CMPLX(src_real,src_imag)
  DEALLOCATE (src_real,src_imag)
  !$OMP TARGET map(to: src) map(from: dst) private(idx)
  !$OMP TEAMS private(idx)
  !$OMP DISTRIBUTE
  DO i0 = 1, N0
    !$OMP PARALLEL DO private(idx)
    DO i1 = 1, N1
      !$OMP SIMD private(idx)
      DO i2 = 1, N2
        idx = i2-1+N2*(i1-1+N1*(i0-1))+1
        dst(idx) = src(idx)
      END DO
    END DO
  END DO
  !$OMP END TEAMS
  !$OMP END TARGET
  IF (ANY(ABS(dst - src) > EPSILON(REAL(src)))) THEN
    WRITE(*,*) 'Wrong value', MAXVAL(ABS(DST-SRC)), 'max difference'
    errno = 112
  ENDIF
  DEALLOCATE(src, dst)
  IF (errno .EQ. 112) STOP 112
END PROGRAM target__teams__distribute__parallel_do__simd
