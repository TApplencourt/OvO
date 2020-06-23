PROGRAM target__teams_distribute__simd
  implicit none
  INTEGER :: N0 = 512
  INTEGER :: i0
  INTEGER :: N1 = 512
  INTEGER :: i1
  INTEGER :: idx, S
  INTEGER :: errno = 0
  DOUBLE COMPLEX, ALLOCATABLE :: src(:)
  DOUBLE COMPLEX, ALLOCATABLE :: dst(:)
  REAL, ALLOCATABLE :: src_real(:)
  REAL, ALLOCATABLE :: src_imag(:)
  S = N0*N1
  ALLOCATE(dst(S), src(S) )
  ALLOCATE(src_real(S),src_imag(S))
  CALL RANDOM_NUMBER(src_real)
  CALL RANDOM_NUMBER(src_imag)
  src = CMPLX(src_real,src_imag)
  DEALLOCATE (src_real,src_imag)
  !$OMP target map(to: src) map(from: dst)
  !$OMP teams distribute
  DO i0 = 1, N0
    !$OMP simd
    DO i1 = 1, N1
      idx = i1-1+N1*(i0-1)+1
      dst(idx) = src(idx)
    END DO
  END DO
  !$OMP END target
  IF (ANY(ABS(dst - src) > EPSILON(REAL(src)))) THEN
    WRITE(*,*)  'Wrong value', MAXVAL(ABS(DST-SRC)), 'max difference'
    errno = 112
  ENDIF
  DEALLOCATE(src, dst)
  IF (errno .NE. 0) STOP errno
END PROGRAM target__teams_distribute__simd
