
#ifndef _OPENMP

MODULE OMP_LIB_STUB
implicit none

CONTAINS


FUNCTION omp_get_num_teams() RESULT(i)
    INTEGER :: i
    i = 1
END FUNCTION omp_get_num_teams

FUNCTION omp_get_num_threads() RESULT(i)
    INTEGER :: i
    i = 1
END FUNCTION omp_get_num_threads


END MODULE OMP_LIB_STUB
#endif


program target__teams__parallel_loop.f90

#ifdef _OPENMP
    USE OMP_LIB
#else
    USE OMP_LIB_STUB
#endif


    implicit none
  
    INTEGER :: L = 5
    INTEGER :: i
    
    REAL :: COUNTER = 0

    
    INTEGER :: num_teams
    
    

     
    
    !$OMP TARGET   MAP(TOFROM: COUNTER) 



    

    
    !$OMP TEAMS 



    
    num_teams = omp_get_num_teams()
    

    
    !$OMP PARALLEL LOOP 


    DO i = 1 , L 


    

    

!$OMP ATOMIC UPDATE

counter = counter + 1./num_teams


 
     

    END DO

    !$OMP END PARALLEL LOOP
     

    !$OMP END TEAMS
     

    !$OMP END TARGET
    

    IF  ( ( ABS(COUNTER - L) ) > 10*EPSILON(COUNTER) ) THEN
        write(*,*)  'Expected L Got', COUNTER
        call exit(1)
    ENDIF

end program target__teams__parallel_loop.f90