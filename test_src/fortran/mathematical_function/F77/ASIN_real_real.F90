program test_ASIN
   implicit none
   CHARACTER(len=255) :: usr_precision
   INTEGER :: precision = 4
   INTEGER :: stat
   REAL :: in0 = ( 0.42 )
   REAL :: o_host, o_device
    CALL GET_ENVIRONMENT_VARIABLE("OVO_TOL_ULP",usr_precision, status=stat)
    IF (stat == 0) THEN
        read(usr_precision, *, iostat=stat) precision
    ENDIF
    !$OMP target map(from:o_device)
    o_device = ASIN( in0)
    !$OMP END TARGET
    IF ( ABS(SIN(o_device) - in0) > EPSILON( in0 )*2*precision ) THEN
            write(*,*) 'Expected ', in0, ' Got ', SIN(o_device)
            STOP 112
    ENDIF
end program test_ASIN
