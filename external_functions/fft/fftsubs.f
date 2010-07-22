*  fftsubs.F
*
*  This software was developed by the Thermal Modeling and Analysis
*  Project(TMAP) of the National Oceanographic and Atmospheric
*  Administration's (NOAA) Pacific Marine Environmental Lab(PMEL),
*  hereafter referred to as NOAA/PMEL/TMAP.
*
*  Access and use of this software shall impose the following
*  obligations and understandings on the user. The user is granted the
*  right, without any fee or cost, to use, copy, modify, alter, enhance
*  and distribute this software, and any derivative works thereof, and
*  its supporting documentation for any purpose whatsoever, provided
*  that this entire notice appears in all copies of the software,
*  derivative works and supporting documentation.  Further, the user
*  agrees to credit NOAA/PMEL/TMAP in any publications that result from
*  the use of this software or in any product that includes this
*  software. The names TMAP, NOAA and/or PMEL, however, may not be used
*  in any advertising or publicity to endorse or promote any products
*  or commercial entity unless specific written permission is obtained
*  from NOAA/PMEL/TMAP. The user also understands that NOAA/PMEL/TMAP
*  is not obligated to provide the user with any support, consulting,
*  training or assistance of any kind with regard to the use, operation
*  and performance of this software nor to provide the user with any
*  updates, revisions, new versions or "bug fixes".
*
*  THIS SOFTWARE IS PROVIDED BY NOAA/PMEL/TMAP "AS IS" AND ANY EXPRESS
*  OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
*  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
*  ARE DISCLAIMED. IN NO EVENT SHALL NOAA/PMEL/TMAP BE LIABLE FOR ANY SPECIAL,
*  INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER
*  RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF
*  CONTRACT, NEGLIGENCE OR OTHER TORTUOUS ACTION, ARISING OUT OF OR IN
*  CONNECTION WITH THE ACCESS, USE OR PERFORMANCE OF THIS SOFTWARE. 
* 
*   computation routines for FFT functions

      SUBROUTINE four_re (nd, x, a, b, wft)
      INTEGER nd, nf, i, j
      REAL x(*), wft(*) 
      REAL a(*), b(*), xn

c   uses NCAR FFTPACK code

C  Ansley Manke 1/2000 NOAA/PMEL   Return A, B real arrays with Fourier coefficients.
C  Uses notes by Ned Cokelet 1/2000 on Swartztrauber FFTPACK code.

c   Calls: RFFTF


C  NF = number of frequencies, half the number of times.
C  The code returns frequencies W(i) for i=0 to ND/2, with ND/2 rounded down.
C  We do not return a(0) = R1/ND
C  We return a(i) and b(i) for i=1,... ND/2  

      nf = nd/ 2

      CALL rfftf (nd, x, wft) 

C  Normalizing factor of 1./N

c      xn = 1.0
      xn = 1.0/ REAL(nd)

c   Save FFT coefficients in arrays a and b.
      
      j = 0
      DO i = 1, nf-1
        j = 2* i
        a(i) =  2.* xn* x(j)
        b(i) = -2.* xn* x(j+1) 
      ENDDO

C  Set a(nf) and b(nf) when nd is even/odd.

      IF (nf*2 .eq. nd) THEN		! even ND
         a(nf) = xn* x(nd)
         b(nf) = 0.
      ELSE				! odd ND
         a(nf) = 2.* xn* x(nd-1)
         b(nf) = -2.* xn* x(nd)
      ENDIF

      RETURN 
      END

                                                                 
C     SUBROUTINE RFFTF(N,R,WSAVE)                                               
C                                                                               
C     SUBROUTINE RFFTF COMPUTES THE FOURIER COEFFICIENTS OF A REAL              
C     PERODIC SEQUENCE (FOURIER ANALYSIS). THE TRANSFORM IS DEFINED             
C     BELOW AT OUTPUT PARAMETER R.                                              
C                                                                               
C     INPUT PARAMETERS                                                          
C                                                                               
C     N       THE LENGTH OF THE ARRAY R TO BE TRANSFORMED.  THE METHOD          
C             IS MOST EFFICIENT WHEN N IS A PRODUCT OF SMALL PRIMES.            
C             N MAY CHANGE SO LONG AS DIFFERENT WORK ARRAYS ARE PROVIDED        
C                                                                               
C     R       A REAL ARRAY OF LENGTH N WHICH CONTAINS THE SEQUENCE              
C             TO BE TRANSFORMED                                                 
C                                                                               
C     WSAVE   A WORK ARRAY WHICH MUST BE DIMENSIONED AT LEAST 2*N+15.           
C             IN THE PROGRAM THAT CALLS RFFTF. THE WSAVE ARRAY MUST BE          
C             INITIALIZED BY CALLING SUBROUTINE RFFTI(N,WSAVE) AND A            
C             DIFFERENT WSAVE ARRAY MUST BE USED FOR EACH DIFFERENT             
C             VALUE OF N. THIS INITIALIZATION DOES NOT HAVE TO BE               
C             REPEATED SO LONG AS N REMAINS UNCHANGED THUS SUBSEQUENT           
C             TRANSFORMS CAN BE OBTAINED FASTER THAN THE FIRST.                 
C             THE SAME WSAVE ARRAY CAN BE USED BY RFFTF AND RFFTB.              
C                                                                               
C                                                                               
C     OUTPUT PARAMETERS                                                         
C                                                                               
C     R       R(1) = THE SUM FROM I=1 TO I=N OF R(I)                            
C                                                                               
C             IF N IS EVEN SET L =N/2   , IF N IS ODD SET L = (N+1)/2           
C                                                                               
C               THEN FOR K = 2,...,L                                            
C                                                                               
C                  R(2*K-2) = THE SUM FROM I = 1 TO I = N OF                    
C                                                                               
C                       R(I)*COS((K-1)*(I-1)*2*PI/N)                            
C                                                                               
C                  R(2*K-1) = THE SUM FROM I = 1 TO I = N OF                    
C                                                                               
C                      -R(I)*SIN((K-1)*(I-1)*2*PI/N)                            
C                                                                               
C             IF N IS EVEN                                                      
C                                                                               
C                  R(N) = THE SUM FROM I = 1 TO I = N OF                        
C                                                                               
C                       (-1)**(I-1)*R(I)                                        
C                                                                               
C      *****  NOTE                                                              
C                  THIS TRANSFORM IS UNNORMALIZED SINCE A CALL OF RFFTF         
C                  FOLLOWED BY A CALL OF RFFTB WILL MULTIPLY THE INPUT          
C                  SEQUENCE BY N.                                               
C                                                                               
C     WSAVE   CONTAINS RESULTS WHICH MUST NOT BE DESTROYED BETWEEN              
C             CALLS OF RFFTF OR RFFTB.                                          
C                                                                               
      SUBROUTINE RFFTF (N,R,WSAVE)                                              
      INTEGER N
      REAL       R(*)       ,WSAVE(*)             
C                                                                               
      IF (N .EQ. 1) RETURN                                                      
      CALL RFFTF1 (N,R,WSAVE,WSAVE(N+1),WSAVE(2*N+1))                           
      RETURN                                                                    
      END                                                                       
      SUBROUTINE RFFTF1 (N,C,CH,WA,IFAC)                                        
      INTEGER N, NF, NA, L2, IW, K1, KH, IP, L1, IDO, IDL1, IX2, IX3
      INTEGER I, IX4
      REAL       CH(*)      ,C(*)       ,WA(*)      ,IFAC(*)   
      NF = IFAC(2)                                                              
      NA = 1                                                                    
      L2 = N                                                                    
      IW = N                                                                    
      DO 111 K1=1,NF                                                            
         KH = NF-K1                                                             
         IP = IFAC(KH+3)                                                        
         L1 = L2/IP                                                             
         IDO = N/L2                                                             
         IDL1 = IDO*L1                                                          
         IW = IW-(IP-1)*IDO                                                     
         NA = 1-NA                                                              
         IF (IP .NE. 4) GO TO 102                                               
         IX2 = IW+IDO                                                           
         IX3 = IX2+IDO                                                          
         IF (NA .NE. 0) GO TO 101                                               
         CALL RADF4 (IDO,L1,C,CH,WA(IW),WA(IX2),WA(IX3))                        
         GO TO 110                                                              
  101    CALL RADF4 (IDO,L1,CH,C,WA(IW),WA(IX2),WA(IX3))                        
         GO TO 110                                                              
  102    IF (IP .NE. 2) GO TO 104                                               
         IF (NA .NE. 0) GO TO 103                                               
         CALL RADF2 (IDO,L1,C,CH,WA(IW))                                        
         GO TO 110                                                              
  103    CALL RADF2 (IDO,L1,CH,C,WA(IW))                                        
         GO TO 110                                                              
  104    IF (IP .NE. 3) GO TO 106                                               
         IX2 = IW+IDO                                                           
         IF (NA .NE. 0) GO TO 105                                               
         CALL RADF3 (IDO,L1,C,CH,WA(IW),WA(IX2))                                
         GO TO 110                                                              
  105    CALL RADF3 (IDO,L1,CH,C,WA(IW),WA(IX2))                                
         GO TO 110                                                              
  106    IF (IP .NE. 5) GO TO 108                                               
         IX2 = IW+IDO                                                           
         IX3 = IX2+IDO                                                          
         IX4 = IX3+IDO                                                          
         IF (NA .NE. 0) GO TO 107                                               
         CALL RADF5 (IDO,L1,C,CH,WA(IW),WA(IX2),WA(IX3),WA(IX4))                
         GO TO 110                                                              
  107    CALL RADF5 (IDO,L1,CH,C,WA(IW),WA(IX2),WA(IX3),WA(IX4))                
         GO TO 110                                                              
  108    IF (IDO .EQ. 1) NA = 1-NA                                              
         IF (NA .NE. 0) GO TO 109                                               
         CALL RADFG (IDO,IP,L1,IDL1,C,C,C,CH,CH,WA(IW))                         
         NA = 1                                                                 
         GO TO 110                                                              
  109    CALL RADFG (IDO,IP,L1,IDL1,CH,CH,CH,C,C,WA(IW))                        
         NA = 0                                                                 
  110    L2 = L1                                                                
  111 CONTINUE                                                                  
      IF (NA .EQ. 1) RETURN                                                     
      DO 112 I=1,N                                                              
         C(I) = CH(I)                                                           
  112 CONTINUE                                                                  
      RETURN                                                                    
      END                         
                                                                    
C     SUBROUTINE RFFTI(N,WSAVE)                                                 
C                                                                               
C     SUBROUTINE RFFTI INITIALIZES THE ARRAY WSAVE WHICH IS USED IN             
C     BOTH RFFTF AND RFFTB. THE PRIME FACTORIZATION OF N TOGETHER WITH          
C     A TABULATION OF THE TRIGONOMETRIC FUNCTIONS ARE COMPUTED AND              
C     STORED IN WSAVE.                                                          
C                                                                               
C     INPUT PARAMETER                                                           
C                                                                               
C     N       THE LENGTH OF THE SEQUENCE TO BE TRANSFORMED.                     
C                                                                               
C     OUTPUT PARAMETER                                                          
C                                                                               
C     WSAVE   A WORK ARRAY WHICH MUST BE DIMENSIONED AT LEAST 2*N+15.           
C             THE SAME WORK ARRAY CAN BE USED FOR BOTH RFFTF AND RFFTB          
C             AS LONG AS N REMAINS UNCHANGED. DIFFERENT WSAVE ARRAYS            
C             ARE REQUIRED FOR DIFFERENT VALUES OF N. THE CONTENTS OF           
C             WSAVE MUST NOT BE CHANGED BETWEEN CALLS OF RFFTF OR RFFTB.        
C                                                                               
      SUBROUTINE RFFTI (N,WSAVE)      
      INTEGER N
      REAL       WSAVE(*)                                                  
C                                                                               
      IF (N .EQ. 1) RETURN                                                      
      CALL RFFTI1 (N,WSAVE(N+1),WSAVE(2*N+1))                                   
      RETURN                                                                    
      END                                                                       
      SUBROUTINE RFFTI1 (N,WA,IFAC)                                             
      INTEGER N, NL, NF, J, NTRY, NR, NQ, IB, I, IS, L1, NFM1, K1
      INTEGER IP, LD, IDO, IPM, II, L2
      REAL       WA(*)      ,IFAC(*)    ,NTRYH(4)         
      REAL TPI, ARGH, ARGLD, FI, ARG, DUM
      REAL PIMACH
      DATA NTRYH(1),NTRYH(2),NTRYH(3),NTRYH(4)/4,2,3,5/                         
      NL = N                                                                    
      NF = 0                                                                    
      J = 0                                                                     
  101 J = J+1                                                                   
      IF (J-4) 102,102,103                                                      
  102 NTRY = NTRYH(J)                                                           
      GO TO 104                                                                 
  103 NTRY = NTRY+2                                                             
  104 NQ = NL/NTRY                                                              
      NR = NL-NTRY*NQ                                                           
      IF (NR) 101,105,101                                                       
  105 NF = NF+1                                                                 
      IFAC(NF+2) = NTRY                                                         
      NL = NQ                                                                   
      IF (NTRY .NE. 2) GO TO 107                                                
      IF (NF .EQ. 1) GO TO 107                                                  
      DO 106 I=2,NF                                                             
         IB = NF-I+2                                                            
         IFAC(IB+2) = IFAC(IB+1)                                                
  106 CONTINUE                                                                  
      IFAC(3) = 2                                                               
  107 IF (NL .NE. 1) GO TO 104                                                  
      IFAC(1) = N                                                               
      IFAC(2) = NF                                                              
      TPI = 2.0*PIMACH(DUM)                                                     
      ARGH = TPI/FLOAT(N)                                                       
      IS = 0                                                                    
      NFM1 = NF-1                                                               
      L1 = 1                                                                    
      IF (NFM1 .EQ. 0) RETURN                                                   
      DO 110 K1=1,NFM1                                                          
         IP = IFAC(K1+2)                                                        
         LD = 0                                                                 
         L2 = L1*IP                                                             
         IDO = N/L2                                                             
         IPM = IP-1                                                             
         DO 109 J=1,IPM                                                         
            LD = LD+L1                                                          
            I = IS                                                              
            ARGLD = FLOAT(LD)*ARGH                                              
            FI = 0.                                                             
            DO 108 II=3,IDO,2                                                   
               I = I+2                                                          
               FI = FI+1.                                                       
               ARG = FI*ARGLD                                                   
               WA(I-1) = COS(ARG)                                               
               WA(I) = SIN(ARG)                                                 
  108       CONTINUE                                                            
            IS = IS+IDO                                                         
  109    CONTINUE                                                               
         L1 = L2                                                                
  110 CONTINUE                                                                  
      RETURN                                                                    
      END
   
      
      REAL FUNCTION PIMACH (DUM)                      
C     PI=3.1415926535897932384626433832795028841971693993751058209749446        
C                            
      REAL DUM
      PIMACH = 4.*ATAN(1.0)                                                     
      RETURN                                                                    
      END    
                                                                            
      SUBROUTINE RADFG (IDO,IP,L1,IDL1,CC,C1,C2,CH,CH2,WA)                      
      INTEGER IDO, IP, L1, IDL1, IPPH, IPP2, IDP2, NBD, IK, J, K, IS
      INTEGER IDIJ, I, JC, L, LC, J2, IC
      REAL       CH(IDO,L1,IP)          ,CC(IDO,IP,L1)          ,          
     1                C1(IDO,L1,IP)          ,C2(IDL1,IP),                      
     2                CH2(IDL1,IP)           ,WA(*)

      REAL TPI, DUM, ARG, DCP, DSP, AR1, AI1, AR1H, DC2, DS2, AR2, AI2
      REAL AR2H
      REAL PIMACH
      TPI = 2.0*PIMACH(DUM)                                                     
      ARG = TPI/FLOAT(IP)                                                       
      DCP = COS(ARG)                                                            
      DSP = SIN(ARG)                                                            
      IPPH = (IP+1)/2                                                           
      IPP2 = IP+2                                                               
      IDP2 = IDO+2                                                              
      NBD = (IDO-1)/2                                                           
      IF (IDO .EQ. 1) GO TO 119                                                 
      DO 101 IK=1,IDL1                                                          
         CH2(IK,1) = C2(IK,1)                                                   
  101 CONTINUE                                                                  
      DO 103 J=2,IP                                                             
         DO 102 K=1,L1                                                          
            CH(1,K,J) = C1(1,K,J)                                               
  102    CONTINUE                                                               
  103 CONTINUE                                                                  
      IF (NBD .GT. L1) GO TO 107                                                
      IS = -IDO                                                                 
      DO 106 J=2,IP                                                             
         IS = IS+IDO                                                            
         IDIJ = IS                                                              
         DO 105 I=3,IDO,2                                                       
            IDIJ = IDIJ+2                                                       
            DO 104 K=1,L1                                                       
               CH(I-1,K,J) = WA(IDIJ-1)*C1(I-1,K,J)+WA(IDIJ)*C1(I,K,J)          
               CH(I,K,J) = WA(IDIJ-1)*C1(I,K,J)-WA(IDIJ)*C1(I-1,K,J)            
  104       CONTINUE                                                            
  105    CONTINUE                                                               
  106 CONTINUE                                                                  
      GO TO 111                                                                 
  107 IS = -IDO                                                                 
      DO 110 J=2,IP                                                             
         IS = IS+IDO                                                            
         DO 109 K=1,L1                                                          
            IDIJ = IS                                                           
            DO 108 I=3,IDO,2                                                    
               IDIJ = IDIJ+2                                                    
               CH(I-1,K,J) = WA(IDIJ-1)*C1(I-1,K,J)+WA(IDIJ)*C1(I,K,J)          
               CH(I,K,J) = WA(IDIJ-1)*C1(I,K,J)-WA(IDIJ)*C1(I-1,K,J)            
  108       CONTINUE                                                            
  109    CONTINUE                                                               
  110 CONTINUE                                                                  
  111 IF (NBD .LT. L1) GO TO 115                                                
      DO 114 J=2,IPPH                                                           
         JC = IPP2-J                                                            
         DO 113 K=1,L1                                                          
            DO 112 I=3,IDO,2                                                    
               C1(I-1,K,J) = CH(I-1,K,J)+CH(I-1,K,JC)                           
               C1(I-1,K,JC) = CH(I,K,J)-CH(I,K,JC)                              
               C1(I,K,J) = CH(I,K,J)+CH(I,K,JC)                                 
               C1(I,K,JC) = CH(I-1,K,JC)-CH(I-1,K,J)                            
  112       CONTINUE                                                            
  113    CONTINUE                                                               
  114 CONTINUE                                                                  
      GO TO 121                                                                 
  115 DO 118 J=2,IPPH                                                           
         JC = IPP2-J                                                            
         DO 117 I=3,IDO,2                                                       
            DO 116 K=1,L1                                                       
               C1(I-1,K,J) = CH(I-1,K,J)+CH(I-1,K,JC)                           
               C1(I-1,K,JC) = CH(I,K,J)-CH(I,K,JC)                              
               C1(I,K,J) = CH(I,K,J)+CH(I,K,JC)                                 
               C1(I,K,JC) = CH(I-1,K,JC)-CH(I-1,K,J)                            
  116       CONTINUE                                                            
  117    CONTINUE                                                               
  118 CONTINUE                                                                  
      GO TO 121                                                                 
  119 DO 120 IK=1,IDL1                                                          
         C2(IK,1) = CH2(IK,1)                                                   
  120 CONTINUE                                                                  
  121 DO 123 J=2,IPPH                                                           
         JC = IPP2-J                                                            
         DO 122 K=1,L1                                                          
            C1(1,K,J) = CH(1,K,J)+CH(1,K,JC)                                    
            C1(1,K,JC) = CH(1,K,JC)-CH(1,K,J)                                   
  122    CONTINUE                                                               
  123 CONTINUE                                                                  
C                                                                               
      AR1 = 1.                                                                  
      AI1 = 0.                                                                  
      DO 127 L=2,IPPH                                                           
         LC = IPP2-L                                                            
         AR1H = DCP*AR1-DSP*AI1                                                 
         AI1 = DCP*AI1+DSP*AR1                                                  
         AR1 = AR1H                                                             
         DO 124 IK=1,IDL1                                                       
            CH2(IK,L) = C2(IK,1)+AR1*C2(IK,2)                                   
            CH2(IK,LC) = AI1*C2(IK,IP)                                          
  124    CONTINUE                                                               
         DC2 = AR1                                                              
         DS2 = AI1                                                              
         AR2 = AR1                                                              
         AI2 = AI1                                                              
         DO 126 J=3,IPPH                                                        
            JC = IPP2-J                                                         
            AR2H = DC2*AR2-DS2*AI2                                              
            AI2 = DC2*AI2+DS2*AR2                                               
            AR2 = AR2H                                                          
            DO 125 IK=1,IDL1                                                    
               CH2(IK,L) = CH2(IK,L)+AR2*C2(IK,J)                               
               CH2(IK,LC) = CH2(IK,LC)+AI2*C2(IK,JC)                            
  125       CONTINUE                                                            
  126    CONTINUE                                                               
  127 CONTINUE                                                                  
      DO 129 J=2,IPPH                                                           
         DO 128 IK=1,IDL1                                                       
            CH2(IK,1) = CH2(IK,1)+C2(IK,J)                                      
  128    CONTINUE                                                               
  129 CONTINUE                                                                  
C                                                                               
      IF (IDO .LT. L1) GO TO 132                                                
      DO 131 K=1,L1                                                             
         DO 130 I=1,IDO                                                         
            CC(I,1,K) = CH(I,K,1)                                               
  130    CONTINUE                                                               
  131 CONTINUE                                                                  
      GO TO 135                                                                 
  132 DO 134 I=1,IDO                                                            
         DO 133 K=1,L1                                                          
            CC(I,1,K) = CH(I,K,1)                                               
  133    CONTINUE                                                               
  134 CONTINUE                                                                  
  135 DO 137 J=2,IPPH                                                           
         JC = IPP2-J                                                            
         J2 = J+J                                                               
         DO 136 K=1,L1                                                          
            CC(IDO,J2-2,K) = CH(1,K,J)                                          
            CC(1,J2-1,K) = CH(1,K,JC)                                           
  136    CONTINUE                                                               
  137 CONTINUE                                                                  
      IF (IDO .EQ. 1) RETURN                                                    
      IF (NBD .LT. L1) GO TO 141                                                
      DO 140 J=2,IPPH                                                           
         JC = IPP2-J                                                            
         J2 = J+J                                                               
         DO 139 K=1,L1                                                          
            DO 138 I=3,IDO,2                                                    
               IC = IDP2-I                                                      
               CC(I-1,J2-1,K) = CH(I-1,K,J)+CH(I-1,K,JC)                        
               CC(IC-1,J2-2,K) = CH(I-1,K,J)-CH(I-1,K,JC)                       
               CC(I,J2-1,K) = CH(I,K,J)+CH(I,K,JC)                              
               CC(IC,J2-2,K) = CH(I,K,JC)-CH(I,K,J)                             
  138       CONTINUE                                                            
  139    CONTINUE                                                               
  140 CONTINUE                                                                  
      RETURN                                                                    
  141 DO 144 J=2,IPPH                                                           
         JC = IPP2-J                                                            
         J2 = J+J                                                               
         DO 143 I=3,IDO,2                                                       
            IC = IDP2-I                                                         
            DO 142 K=1,L1                                                       
               CC(I-1,J2-1,K) = CH(I-1,K,J)+CH(I-1,K,JC)                        
               CC(IC-1,J2-2,K) = CH(I-1,K,J)-CH(I-1,K,JC)                       
               CC(I,J2-1,K) = CH(I,K,J)+CH(I,K,JC)                              
               CC(IC,J2-2,K) = CH(I,K,JC)-CH(I,K,J)                             
  142       CONTINUE                                                            
  143    CONTINUE                                                               
  144 CONTINUE                                                                  
      RETURN                                                                    
      END                         
                                                                       
      SUBROUTINE RADF5 (IDO,L1,CC,CH,WA1,WA2,WA3,WA4)                           
      INTEGER IDO, L1, K, IDP2, I, IC
      REAL       CC(IDO,L1,5)           ,CH(IDO,5,L1)           ,          
     1                WA1(*)     ,WA2(*)     ,WA3(*)     ,WA4(*)    
      REAL CR2, CR3, CR4, CR5, CI2, CI3, CI4, CI5
      REAL TR2, TR3, TR4, TR5, TI2, TI3, TI4, TI5
      REAL DR2, DR3, DR4, DR5, DI2, DI3, DI4, DI5
      REAL TR11, TI11, TR12, TI12
      DATA TR11,TI11,TR12,TI12 /.309016994374947,.951056516295154,              
     1-.809016994374947,.587785252292473/                                       
      DO 101 K=1,L1                                                             
         CR2 = CC(1,K,5)+CC(1,K,2)                                              
         CI5 = CC(1,K,5)-CC(1,K,2)                                              
         CR3 = CC(1,K,4)+CC(1,K,3)                                              
         CI4 = CC(1,K,4)-CC(1,K,3)                                              
         CH(1,1,K) = CC(1,K,1)+CR2+CR3                                          
         CH(IDO,2,K) = CC(1,K,1)+TR11*CR2+TR12*CR3                              
         CH(1,3,K) = TI11*CI5+TI12*CI4                                          
         CH(IDO,4,K) = CC(1,K,1)+TR12*CR2+TR11*CR3                              
         CH(1,5,K) = TI12*CI5-TI11*CI4                                          
  101 CONTINUE                                                                  
      IF (IDO .EQ. 1) RETURN                                                    
      IDP2 = IDO+2                                                              
      DO 103 K=1,L1                                                             
         DO 102 I=3,IDO,2                                                       
            IC = IDP2-I                                                         
            DR2 = WA1(I-2)*CC(I-1,K,2)+WA1(I-1)*CC(I,K,2)                       
            DI2 = WA1(I-2)*CC(I,K,2)-WA1(I-1)*CC(I-1,K,2)                       
            DR3 = WA2(I-2)*CC(I-1,K,3)+WA2(I-1)*CC(I,K,3)                       
            DI3 = WA2(I-2)*CC(I,K,3)-WA2(I-1)*CC(I-1,K,3)                       
            DR4 = WA3(I-2)*CC(I-1,K,4)+WA3(I-1)*CC(I,K,4)                       
            DI4 = WA3(I-2)*CC(I,K,4)-WA3(I-1)*CC(I-1,K,4)                       
            DR5 = WA4(I-2)*CC(I-1,K,5)+WA4(I-1)*CC(I,K,5)                       
            DI5 = WA4(I-2)*CC(I,K,5)-WA4(I-1)*CC(I-1,K,5)                       
            CR2 = DR2+DR5                                                       
            CI5 = DR5-DR2                                                       
            CR5 = DI2-DI5                                                       
            CI2 = DI2+DI5                                                       
            CR3 = DR3+DR4                                                       
            CI4 = DR4-DR3                                                       
            CR4 = DI3-DI4                                                       
            CI3 = DI3+DI4                                                       
            CH(I-1,1,K) = CC(I-1,K,1)+CR2+CR3                                   
            CH(I,1,K) = CC(I,K,1)+CI2+CI3                                       
            TR2 = CC(I-1,K,1)+TR11*CR2+TR12*CR3                                 
            TI2 = CC(I,K,1)+TR11*CI2+TR12*CI3                                   
            TR3 = CC(I-1,K,1)+TR12*CR2+TR11*CR3                                 
            TI3 = CC(I,K,1)+TR12*CI2+TR11*CI3                                   
            TR5 = TI11*CR5+TI12*CR4                                             
            TI5 = TI11*CI5+TI12*CI4                                             
            TR4 = TI12*CR5-TI11*CR4                                             
            TI4 = TI12*CI5-TI11*CI4                                             
            CH(I-1,3,K) = TR2+TR5                                               
            CH(IC-1,2,K) = TR2-TR5                                              
            CH(I,3,K) = TI2+TI5                                                 
            CH(IC,2,K) = TI5-TI2                                                
            CH(I-1,5,K) = TR3+TR4                                               
            CH(IC-1,4,K) = TR3-TR4                                              
            CH(I,5,K) = TI3+TI4                                                 
            CH(IC,4,K) = TI4-TI3                                                
  102    CONTINUE                                                               
  103 CONTINUE                                                                  
      RETURN                                                                    
      END                           
                                                                  
      SUBROUTINE RADF2 (IDO,L1,CC,CH,WA1)                                       
      INTEGER IDO, L1, K, IDP2, I, IC
      REAL       CH(IDO,2,L1)           ,CC(IDO,L1,2)           ,          
     1                WA1(*)           
      REAL TR2, TI2
      DO 101 K=1,L1                                                             
         CH(1,1,K) = CC(1,K,1)+CC(1,K,2)                                        
         CH(IDO,2,K) = CC(1,K,1)-CC(1,K,2)                                      
  101 CONTINUE                                                                  
      IF (IDO-2) 107,105,102                                                    
  102 IDP2 = IDO+2                                                              
      DO 104 K=1,L1                                                             
         DO 103 I=3,IDO,2                                                       
            IC = IDP2-I                                                         
            TR2 = WA1(I-2)*CC(I-1,K,2)+WA1(I-1)*CC(I,K,2)                       
            TI2 = WA1(I-2)*CC(I,K,2)-WA1(I-1)*CC(I-1,K,2)                       
            CH(I,1,K) = CC(I,K,1)+TI2                                           
            CH(IC,2,K) = TI2-CC(I,K,1)                                          
            CH(I-1,1,K) = CC(I-1,K,1)+TR2                                       
            CH(IC-1,2,K) = CC(I-1,K,1)-TR2                                      
  103    CONTINUE                                                               
  104 CONTINUE                                                                  
      IF (MOD(IDO,2) .EQ. 1) RETURN                                             
  105 DO 106 K=1,L1                                                             
         CH(1,2,K) = -CC(IDO,K,2)                                               
         CH(IDO,1,K) = CC(IDO,K,1)                                              
  106 CONTINUE                                                                  
  107 RETURN                                                                    
      END      
                                                                       
      SUBROUTINE RADF3 (IDO,L1,CC,CH,WA1,WA2)                                   
      INTEGER IDO, L1, I, IC, K, IDP2
      REAL       CH(IDO,3,L1)           ,CC(IDO,L1,3)           ,          
     1                WA1(*)     ,WA2(*)     
      REAL TAUR, TAUI, CR2, DR2, DI2, DR3, DI3, CI2, TR2, TI2, TR3, TI3
      DATA TAUR,TAUI /-.5,.866025403784439/                                     
      DO 101 K=1,L1                                                             
         CR2 = CC(1,K,2)+CC(1,K,3)                                              
         CH(1,1,K) = CC(1,K,1)+CR2                                              
         CH(1,3,K) = TAUI*(CC(1,K,3)-CC(1,K,2))                                 
         CH(IDO,2,K) = CC(1,K,1)+TAUR*CR2                                       
  101 CONTINUE                                                                  
      IF (IDO .EQ. 1) RETURN                                                    
      IDP2 = IDO+2                                                              
      DO 103 K=1,L1                                                             
         DO 102 I=3,IDO,2                                                       
            IC = IDP2-I                                                         
            DR2 = WA1(I-2)*CC(I-1,K,2)+WA1(I-1)*CC(I,K,2)                       
            DI2 = WA1(I-2)*CC(I,K,2)-WA1(I-1)*CC(I-1,K,2)                       
            DR3 = WA2(I-2)*CC(I-1,K,3)+WA2(I-1)*CC(I,K,3)                       
            DI3 = WA2(I-2)*CC(I,K,3)-WA2(I-1)*CC(I-1,K,3)                       
            CR2 = DR2+DR3                                                       
            CI2 = DI2+DI3                                                       
            CH(I-1,1,K) = CC(I-1,K,1)+CR2                                       
            CH(I,1,K) = CC(I,K,1)+CI2                                           
            TR2 = CC(I-1,K,1)+TAUR*CR2                                          
            TI2 = CC(I,K,1)+TAUR*CI2                                            
            TR3 = TAUI*(DI2-DI3)                                                
            TI3 = TAUI*(DR3-DR2)                                                
            CH(I-1,3,K) = TR2+TR3                                               
            CH(IC-1,2,K) = TR2-TR3                                              
            CH(I,3,K) = TI2+TI3                                                 
            CH(IC,2,K) = TI3-TI2                                                
  102    CONTINUE                                                               
  103 CONTINUE                                                                  
      RETURN                                                                    
      END                                                                       
      SUBROUTINE RADF4 (IDO,L1,CC,CH,WA1,WA2,WA3)                               
      INTEGER IDO, L1, K, IDP2, I, IC
      REAL       CC(IDO,L1,4)           ,CH(IDO,4,L1)           ,          
     1                WA1(*)     ,WA2(*)     ,WA3(*)  
      REAL HSQT2
      REAL CR2, CR3, CR4, CI2, CI3, CI4
      REAL TR1, TR2, TR3, TR4, TI1, TI2, TI3, TI4
      DATA HSQT2 /.7071067811865475/                                            
      DO 101 K=1,L1                                                             
         TR1 = CC(1,K,2)+CC(1,K,4)                                              
         TR2 = CC(1,K,1)+CC(1,K,3)                                              
         CH(1,1,K) = TR1+TR2                                                    
         CH(IDO,4,K) = TR2-TR1                                                  
         CH(IDO,2,K) = CC(1,K,1)-CC(1,K,3)                                      
         CH(1,3,K) = CC(1,K,4)-CC(1,K,2)                                        
  101 CONTINUE                                                                  
      IF (IDO-2) 107,105,102                                                    
  102 IDP2 = IDO+2                                                              
      DO 104 K=1,L1                                                             
         DO 103 I=3,IDO,2                                                       
            IC = IDP2-I                                                         
            CR2 = WA1(I-2)*CC(I-1,K,2)+WA1(I-1)*CC(I,K,2)                       
            CI2 = WA1(I-2)*CC(I,K,2)-WA1(I-1)*CC(I-1,K,2)                       
            CR3 = WA2(I-2)*CC(I-1,K,3)+WA2(I-1)*CC(I,K,3)                       
            CI3 = WA2(I-2)*CC(I,K,3)-WA2(I-1)*CC(I-1,K,3)                       
            CR4 = WA3(I-2)*CC(I-1,K,4)+WA3(I-1)*CC(I,K,4)                       
            CI4 = WA3(I-2)*CC(I,K,4)-WA3(I-1)*CC(I-1,K,4)                       
            TR1 = CR2+CR4                                                       
            TR4 = CR4-CR2                                                       
            TI1 = CI2+CI4                                                       
            TI4 = CI2-CI4                                                       
            TI2 = CC(I,K,1)+CI3                                                 
            TI3 = CC(I,K,1)-CI3                                                 
            TR2 = CC(I-1,K,1)+CR3                                               
            TR3 = CC(I-1,K,1)-CR3                                               
            CH(I-1,1,K) = TR1+TR2                                               
            CH(IC-1,4,K) = TR2-TR1                                              
            CH(I,1,K) = TI1+TI2                                                 
            CH(IC,4,K) = TI1-TI2                                                
            CH(I-1,3,K) = TI4+TR3                                               
            CH(IC-1,2,K) = TR3-TI4                                              
            CH(I,3,K) = TR4+TI3                                                 
            CH(IC,2,K) = TR4-TI3                                                
  103    CONTINUE                                                               
  104 CONTINUE                                                                  
      IF (MOD(IDO,2) .EQ. 1) RETURN                                             
  105 CONTINUE                                                                  
      DO 106 K=1,L1                                                             
         TI1 = -HSQT2*(CC(IDO,K,2)+CC(IDO,K,4))                                 
         TR1 = HSQT2*(CC(IDO,K,2)-CC(IDO,K,4))                                  
         CH(IDO,1,K) = TR1+CC(IDO,K,1)                                          
         CH(IDO,3,K) = CC(IDO,K,1)-TR1                                          
         CH(1,2,K) = TI1-CC(IDO,K,3)                                            
         CH(1,4,K) = TI1+CC(IDO,K,3)                                            
  106 CONTINUE                                                                  
  107 RETURN                                                                    
      END                   