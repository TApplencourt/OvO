PROGRAM target_parallel__do
  INTEGER :: N0 = 262144
  INTEGER :: i0
  INTEGER :: idx
  INTEGER :: S
  REAL, ALLOCATABLE :: src(:)
  REAL, ALLOCATABLE :: dst(:)
  S = N0
  ALLOCATE(dst(S), src(S) )
  CALL RANDOM_NUMBER(src)
  !$OMP target parallel map(from: src[0:size]) map(to: dst[0:size])
  !$OMP do
  DO i0 = 1, N0
    idx = i0-1+1
    dst(idx) = src(idx)
  END DO
  !$OMP END target parallel
  IF (ANY(ABS(dst - src) > EPSILON(src))) THEN
    WRITE(*,*)  'Wrong value', MAXVAL(ABS(DST-SRC)), 'max difference'
    STOP 112
  ENDIF
END PROGRAM target_parallel__do
