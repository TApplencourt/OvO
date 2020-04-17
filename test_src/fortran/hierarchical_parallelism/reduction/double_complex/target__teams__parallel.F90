


#ifndef _OPENMP

FUNCTION omp_get_num_teams() RESULT(i) 
    INTEGER :: i
    i = 1
END FUNCTION omp_get_num_teams

FUNCTION omp_get_num_threads() RESULT(i) 
    INTEGER :: i
    i = 1
END FUNCTION omp_get_num_threads

#endif


FUNCTION almost_equal(x, gold, tol) result(b)
    implicit none
    DOUBLE COMPLEX, intent(in) :: x
    INTEGER,  intent(in) ::gold
    REAL, intent(in)  :: tol
    LOGICAL          :: b
    
    b = ( gold * (1 - tol)  <= ABS(x) ).AND.( ABS(x) <= gold * (1+tol)  )
    
END FUNCTION almost_equal

program target__teams__parallel
    implicit none

#ifdef _OPENMP
    USE OMP_LIB
#else
    INTEGER:: omp_get_num_teams, omp_get_num_threads
#endif


    LOGICAL :: almost_equal

  
    
    DOUBLE COMPLEX :: COUNTER =  (    0   ,0)  

    
    INTEGER :: num_teams
    
    
    INTEGER :: num_threads
    
     
    
    !$OMP TARGET    MAP(TOFROM: COUNTER) 



    

    
    !$OMP TEAMS   REDUCTION(+:COUNTER)  



    
    num_teams = omp_get_num_teams()
    

    
    !$OMP PARALLEL   REDUCTION(+:COUNTER)  



    
    num_threads = omp_get_num_threads()
    

    


counter = counter +  CMPLX(   1./(num_teams*num_threads)   ,0) 

 
     

    !$OMP END PARALLEL
     

    !$OMP END TEAMS
     

    !$OMP END TARGET
    

    IF  ( .NOT.almost_equal(COUNTER, 1, 0.1) ) THEN
        write(*,*)  'Expected', 1,  'Got', COUNTER
        call exit(1)
    ENDIF

end program target__teams__parallel