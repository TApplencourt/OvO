
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


program target__teams__parallel__do

#ifdef _OPENMP
    USE OMP_LIB
#else
    USE OMP_LIB_STUB
#endif


    implicit none
  
    INTEGER :: L = 5
    INTEGER :: i
    
    DOUBLE PRECISION :: COUNTER = 0

    
    INTEGER :: num_teams
    
    

     
    
    !$OMP TARGET   MAP(TOFROM: COUNTER) 



    

    
    !$OMP TEAMS 



    
    num_teams = omp_get_num_teams()
    

    
    !$OMP PARALLEL 



    

    
    !$OMP DO 


    DO i = 1 , L 


    

    

!$OMP ATOMIC UPDATE

counter = counter + 1./num_teams


 
     

    END DO

    !$OMP END DO
     

    !$OMP END PARALLEL
     

    !$OMP END TEAMS
     

    !$OMP END TARGET
    

    IF  ( ( ABS(COUNTER - L) ) > 10*EPSILON(COUNTER) ) THEN
        write(*,*)  'Expected L Got', COUNTER
        call exit(1)
    ENDIF

end program target__teams__parallel__do