
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


program target__parallel__simd.f90

#ifdef _OPENMP
    USE OMP_LIB
#else
    USE OMP_LIB_STUB
#endif


    

    implicit none
  
    INTEGER :: L = 5
    INTEGER :: i
    
    DOUBLE PRECISION :: COUNTER =  0   

    
    
    INTEGER :: num_threads
    
     
    
    !$OMP TARGET    MAP(TOFROM: COUNTER) 



    

    
    !$OMP PARALLEL   REDUCTION(+:COUNTER)  



    
    num_threads = omp_get_num_threads()
    

    
    !$OMP SIMD   REDUCTION(+:COUNTER)  


    DO i = 1 , L 


    

    


counter =  counter +  1./num_threads  

 
     

    END DO

    !$OMP END SIMD
     

    !$OMP END PARALLEL
     

    !$OMP END TARGET
    

    IF  ( ( ABS(COUNTER - L) ) > 10*EPSILON( COUNTER   ) ) THEN
        write(*,*)  'Expected L Got', COUNTER
        call exit(1)
    ENDIF

end program target__parallel__simd.f90