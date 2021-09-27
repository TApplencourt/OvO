program test_AMAX0
   implicit none
   CHARACTER(len=255) :: usr_precision
   INTEGER :: precision = 4
   INTEGER :: stat
   INTEGER :: in0 = ( 1 )
   INTEGER :: in1 = ( 1 )
   REAL :: o_host, o_device
    CALL GET_ENVIRONMENT_VARIABLE("OVO_TOL_ULP",usr_precision, status=stat)
    IF (stat == 0) THEN
        read(usr_precision, *, iostat=stat) precision
    ENDIF
    o_host = AMAX0( in0, in1)
    !$OMP target map(from:o_device)
    o_device = AMAX0( in0, in1)
    !$OMP END TARGET
    IF ( ABS(o_host-o_device) > EPSILON( o_host )*precision ) THEN
        write(*,*) 'Expected ', o_host, ' Got ', o_device
        STOP 112
    ENDIF
end program test_AMAX0
