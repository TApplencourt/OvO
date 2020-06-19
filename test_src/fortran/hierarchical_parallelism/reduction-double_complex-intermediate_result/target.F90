FUNCTION almost_equal(x, gold, tol) RESULT(b)
  implicit none
  DOUBLE COMPLEX, intent(in) :: x
  INTEGER,  intent(in) :: gold
  REAL,     intent(in) :: tol
  LOGICAL              :: b
  b = ( gold * (1 - tol)  <= ABS(x) ).AND.( ABS(x) <= gold * (1+tol) )
END FUNCTION almost_equal
PROGRAM target
  LOGICAL :: almost_equal
  DOUBLE COMPLEX :: counter_target
  INTEGER :: expected_value
  expected_value = 1
  counter_target = 0
  !$OMP target map(tofrom: counter_target)
    counter_target = counter_target + 1.
  !$OMP END target
  IF ( .NOT.almost_equal(counter_target,expected_value, 0.1) ) THEN
    WRITE(*,*)  'Expected', expected_value,  'Got', counter_target
    STOP 112
  ENDIF
END PROGRAM target
