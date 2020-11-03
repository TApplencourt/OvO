FUNCTION almost_equal(x, gold, tol) RESULT(b)
  implicit none
  REAL, intent(in) :: x
  INTEGER,  intent(in) :: gold
  REAL,     intent(in) :: tol
  LOGICAL              :: b
  b = ( gold * (1 - tol)  <= x ).AND.( x <= gold * (1+tol) )
END FUNCTION almost_equal
PROGRAM target
  implicit none
  LOGICAL :: almost_equal
  REAL :: counter_target
  INTEGER :: expected_value
  expected_value = 1
  counter_target = 0
  !$OMP TARGET map(tofrom: counter_target)
    counter_target = counter_target + 1.
  !$OMP END TARGET
  IF ( .NOT.almost_equal(counter_target,expected_value, 0.1) ) THEN
    WRITE(*,*)  'Expected', expected_value,  'Got', counter_target
    STOP 112
  ENDIF
END PROGRAM target
