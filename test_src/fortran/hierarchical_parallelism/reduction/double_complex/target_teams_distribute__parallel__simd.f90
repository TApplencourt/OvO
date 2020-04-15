
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


program target_teams_distribute__parallel__simd.f90

#ifdef _OPENMP
    USE OMP_LIB
#else
    USE OMP_LIB_STUB
#endif


    

    implicit none
  
    INTEGER :: L = 5
    INTEGER :: i
    INTEGER :: M = 6
    INTEGER :: j
    
    DOUBLE COMPLEX :: COUNTER =  (    0   ,0)  

    
    
    INTEGER :: num_threads
    
     
    
    !$OMP TARGET TEAMS DISTRIBUTE   REDUCTION(+:COUNTER)   MAP(TOFROM: COUNTER) 


    DO i = 1 , L 


    

    
    !$OMP PARALLEL   REDUCTION(+:COUNTER)  



    
    num_threads = omp_get_num_threads()
    

    
    !$OMP SIMD   REDUCTION(+:COUNTER)  


    DO j = 1 , M 


    

    


counter =  counter +  CMPLX(  1./num_threads   ,0) 

 
     

    END DO

    !$OMP END SIMD
     

    !$OMP END PARALLEL
     

    END DO

    !$OMP END TARGET TEAMS DISTRIBUTE
    

    IF  ( ( ABS(COUNTER - L*M) ) > 10*EPSILON( REAL(  COUNTER  )   ) ) THEN
        write(*,*)  'Expected L*M Got', COUNTER
        call exit(1)
    ENDIF

end program target_teams_distribute__parallel__simd.f90