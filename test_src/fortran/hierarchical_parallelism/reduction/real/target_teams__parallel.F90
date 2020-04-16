
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


program target_teams__parallel

#ifdef _OPENMP
    USE OMP_LIB
#else
    USE OMP_LIB_STUB
#endif


    

    implicit none
  
    
    REAL :: COUNTER =  0   

    
    INTEGER :: num_teams
    
    
    INTEGER :: num_threads
    
     
    
    !$OMP TARGET TEAMS   REDUCTION(+:COUNTER)   MAP(TOFROM: COUNTER) 



    
    num_teams = omp_get_num_teams()
    

    
    !$OMP PARALLEL   REDUCTION(+:COUNTER)  



    
    num_threads = omp_get_num_threads()
    

    


counter = counter +  1./(num_teams*num_threads)  

 
     

    !$OMP END PARALLEL
     

    !$OMP END TARGET TEAMS
    

    IF  ( ( ABS(COUNTER - 1) ) > 10*EPSILON( COUNTER   ) ) THEN
        write(*,*)  'Expected 1 Got', COUNTER
        call exit(1)
    ENDIF

end program target_teams__parallel