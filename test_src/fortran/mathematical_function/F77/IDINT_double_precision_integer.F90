program test_IDINT
   implicit none
   CHARACTER(len=255) :: usr_precision
   INTEGER :: precision = 4
   INTEGER :: stat
   DOUBLE PRECISION :: in0 = ( 0.42 )
   INTEGER :: o_host, o_device
    CALL GET_ENVIRONMENT_VARIABLE("OVO_TOL_ULP",usr_precision, status=stat)
    IF (stat == 0) THEN
        read(usr_precision, *, iostat=stat) precision
    ENDIF
    o_host = IDINT( in0)
    !$OMP target map(from:o_device)
    o_device = IDINT( in0)
    !$OMP END TARGET
    IF ( o_host .ne. o_device ) THEN
        write(*,*) 'Expected ', o_host, ' Got ', o_device
        STOP 112
    ENDIF
end program test_IDINT
