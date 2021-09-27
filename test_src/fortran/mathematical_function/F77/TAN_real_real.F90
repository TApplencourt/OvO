program test_TAN
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
    o_host = TAN( in0)
    !$OMP target map(from:o_device)
    o_device = TAN( in0)
    !$OMP END TARGET
    IF ( ABS(o_host-o_device) > EPSILON( o_host )*precision ) THEN
        write(*,*) 'Expected ', o_host, ' Got ', o_device
        STOP 112
    ENDIF
end program test_TAN
