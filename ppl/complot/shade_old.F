      SUBROUTINE SHADE(XALOW,YALOW,XAHIGH,YAHIGH,XAINT,YAINT,
     * IASHAD)
*
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
*
C**    @(#)shade.f	1.1    3/10/88
C**
C**
C***********************************************************************
C**
C**                 PLOT+ Scientific Graphics System
C**
C***********************************************************************
C**
C**
C
C     CALL SHADE(XLOW,YLOW,XHIGH,YHIGH,XINT,YINT,ISHADE)
C
C     THIS SUBROUTINE SHADES A RECTANGLE WITH ONE OR MORE OF THE
C     FOLLOWING: HORIZONTAL LINES, VERTICAL LINES, UPWARD DIAG-
C     ONAL LINES, AND DOWNWARD DIAGONAL LINES.
C
C     THE VARIOUS PARAMETERS AND THEIR DEFINITIONS ARE LISTED
C     BELOW:
C        XLOW   - X-VALUE OF THE LEFT-HAND SIDE OF THE RECTANGLE
C                 IN USER'S UNITS.
C        YLOW   - Y-VALUE OF THE BOTTOM SIDE OF THE RECTANGLE IN
C                 USER'S UNITS.
C        XHIGH  - X-VALUE OF THE RIGHT-HAND SIDE OF THE RECTAN-
C                 GLE IN USER'S UNITS.
C        YHIGH  - Y-VALUE OF THE TOP SIDE OF THE RECTANGLE IN
C                 USER'S UNITS.
C        XINT   - DISTANCE BETWEEN SUCCESSIVE POINTS OF INTERSEC-
C                 TION OF THE SHADING LINES WITH THE BOTTOM AND
C                 TOP SIDES OF THE RECTANGLE IN USER'S UNITS.
C        YINT   - DISTANCE BETWEEN SUCCESSIVE POINTS OF INTERSEC-
C                 TION OF THE SHADING LINES WITH THE LEFT-HAND
C                 AND RIGHT-HAND SIDES OF THE RECTANGLE IN USER'S
C                 UNITS.
C        ISHADE - CODE INDICATING THE TYPE OF SHADING TO BE
C                 DRAWN.
C
C
      LOGICAL XYF,YXF
C
C     TRANSFER THE PARAMETERS TO NEW VARIABLES.
C
      XLOW = XALOW
      XHIGH = XAHIGH
      YLOW = YALOW
      YHIGH = YAHIGH
      XINT = ABS(XAINT)
      YINT = ABS(YAINT)
      ISHADE = IABS(IASHAD)
C
C     CHECK THE PARAMETERS TO MAKE SURE THAT THEY ARE VALID.
C
      IF(XLOW .LE. XHIGH)GO TO 10
      TEMP = XLOW
      XLOW = XHIGH
      XHIGH = TEMP
   10 IF(YLOW .LE. YHIGH)GO TO 20
      TEMP = YLOW
      YLOW = YHIGH
      YHIGH = TEMP
C
C     SET VECTRS MODE.
C
   20 CALL VECTRS
C
C     DETERMINE WHETHER THE RECTANGLE SHOULD BE SHADED.
C
      IF(XLOW .EQ. XHIGH .OR. YLOW .EQ. YHIGH)GO TO 340
      IF(XINT .EQ. 0.0 .OR. YINT .EQ. 0.0)GO TO 340
C
C     CHECK THE SHADING CODE.
C
# ifdef hp
      IF(IAND(ISHADE,1) .EQ. 0)GO TO 40
# else
      IF(AND(ISHADE,1) .EQ. 0)GO TO 40
# endif
C
C     SHADE THE RECTANGLE WITH HORIZONTAL LINES.
C
      Y1 = YLOW
   30 Y1 = Y1 + YINT
      IF(Y1 .GE. YHIGH)GO TO 40
      CALL PLOT(XLOW,Y1,0,0)
      CALL PLOT(XHIGH,Y1,1,0)
      Y1 = Y1 + YINT
      IF(Y1 .GE. YHIGH)GO TO 40
      CALL PLOT(XHIGH,Y1,0,0)
      CALL PLOT(XLOW,Y1,1,0)
      GO TO 30
C
C     CHECK THE SHADING CODE.
C
# ifdef hp
   40 IF(IAND(ISHADE,2) .EQ. 0)GO TO 60
# else
   40 IF(AND(ISHADE,2) .EQ. 0)GO TO 60
# endif
C
C     SHADE THE RECTANGLE WITH VERTICAL LINES.
C
      X1 = XLOW
   50 X1 = X1 + XINT
      IF(X1 .GE. XHIGH)GO TO 60
      CALL PLOT(X1,YLOW,0,0)
      CALL PLOT(X1,YHIGH,1,0)
      X1 = X1 + XINT
      IF(X1 .GE. XHIGH)GO TO 60
      CALL PLOT(X1,YHIGH,0,0)
      CALL PLOT(X1,YLOW,1,0)
      GO TO 50
C
C     CHECK THE SHADING CODE.
C
# ifdef hp
   60 IF(IAND(ISHADE,4) .EQ. 0)GO TO 200
# else
   60 IF(AND(ISHADE,4) .EQ. 0)GO TO 200
# endif
C
C     SHADE THE RECTANGLE WITH UPWARD DIAGONAL LINES.
C
      X1 = XLOW + XINT * FLOAT(IFIX((XHIGH - XLOW) / XINT))
      IF(X1 .LT. XHIGH)X1 = X1 + XINT
      Y1 = YLOW - YINT * (X1 - XHIGH) / XINT
      XYF = .FALSE.
      YXF = .FALSE.
      GO TO 80
   70 IF(XYF)GO TO 110
C
C     THE LOWER END OF THE LINES INTERSECTS THE BOTTOM SIDE OF
C     THE RECTANGLE.
C
      X1 = X1 - XINT
      IF(X1 .LE. XLOW)GO TO 90
      CALL PLOT(X1,YLOW,1,0)
   80 X1 = X1 - XINT
      IF(X1 .LE. XLOW)GO TO 100
      CALL PLOT(X1,YLOW,0,0)
      GO TO 140
   90 Y2 = YLOW - YINT * (X1 - XLOW) / XINT
      XYF = .TRUE.
      GO TO 120
  100 Y2 = YLOW - YINT * (X1 - XLOW) / XINT
      XYF = .TRUE.
      GO TO 130
C
C     THE LOWER END OF THE LINES INTERSECTS THE LEFT-HAND SIDE
C     OF THE RECTANGLE.
C
  110 Y2 = Y2 + YINT
  120 IF(Y2 .GE. YHIGH)GO TO 200
      CALL PLOT(XLOW,Y2,1,0)
      Y2 = Y2 + YINT
  130 IF(Y2 .GE. YHIGH)GO TO 200
      CALL PLOT(XLOW,Y2,0,0)
  140 IF(YXF)GO TO 170
C
C     THE UPPER END OF THE LINES INTERSECTS THE RIGHT-HAND SIDE
C     OF THE RECTANGLE.
C
      Y1 = Y1 + YINT
      IF(Y1 .GE. YHIGH)GO TO 150
      CALL PLOT(XHIGH,Y1,1,0)
      Y1 = Y1 + YINT
      IF(Y1 .GE. YHIGH)GO TO 160
      CALL PLOT(XHIGH,Y1,0,0)
      GO TO 70
  150 X2 = XHIGH - XINT * (Y1 - YHIGH) / YINT
      YXF = .TRUE.
      GO TO 180
  160 X2 = XHIGH - XINT * (Y1 - YHIGH) / YINT
      YXF = .TRUE.
      GO TO 190
C
C     THE UPPER END OF THE LINES INTERSECTS THE TOP SIDE OF THE
C     RECTANGLE.
C
  170 X2 = X2 - XINT
  180 IF(X2 .LE. XLOW)GO TO 200
      CALL PLOT(X2,YHIGH,1,0)
      X2 = X2 - XINT
  190 IF(X2 .LE. XLOW)GO TO 200
      CALL PLOT(X2,YHIGH,0,0)
      GO TO 70
C
C     CHECK THE SHADING CODE.
C
# ifdef hp
  200 IF(IAND(ISHADE,8) .EQ. 0)GO TO 340
# else
  200 IF(AND(ISHADE,8) .EQ. 0)GO TO 340
# endif
C
C     SHADE THE RECTANGLE WITH DOWNWARD DIAGONAL LINES.
C
      X1 = XLOW
      Y1 = YLOW
      XYF = .FALSE.
      YXF = .FALSE.
      GO TO 220
  210 IF(XYF)GO TO 250
C
C     THE LOWER END OF THE LINES INTERSECTS THE BOTTOM SIDE OF
C     THE RECTANGLE.
C
      X1 = X1 + XINT
      IF(X1 .GE. XHIGH)GO TO 230
      CALL PLOT(X1,YLOW,1,0)
  220 X1 = X1 + XINT
      IF(X1 .GE. XHIGH)GO TO 240
      CALL PLOT(X1,YLOW,0,0)
      GO TO 280
  230 Y2 = YLOW + YINT * (X1 - XHIGH) / XINT
      XYF = .TRUE.
      GO TO 260
  240 Y2 = YLOW + YINT * (X1 - XHIGH) / XINT
      XYF = .TRUE.
      GO TO 270
C
C     THE LOWER END OF THE LINES INTERSECTS THE RIGHT-HAND SIDE
C     OF THE RECTANGLE.
C
  250 Y2 = Y2 + YINT
  260 IF(Y2 .GE. YHIGH)GO TO 340
      CALL PLOT(XHIGH,Y2,1,0)
      Y2 = Y2 + YINT
  270 IF(Y2 .GE. YHIGH)GO TO 340
      CALL PLOT(XHIGH,Y2,0,0)
  280 IF(YXF)GO TO 310
C
C     THE UPPER END OF THE LINES INTERSECTS THE LEFT-HAND SIDE
C     OF THE RECTANGLE.
C
      Y1 = Y1 + YINT
      IF(Y1 .GE. YHIGH)GO TO 290
      CALL PLOT(XLOW,Y1,1,0)
      Y1 = Y1 + YINT
      IF(Y1 .GE. YHIGH)GO TO 300
      CALL PLOT(XLOW,Y1,0,0)
      GO TO 210
  290 X2 = XLOW + XINT * (Y1 - YHIGH) / YINT
      YXF = .TRUE.
      GO TO 320
  300 X2 = XLOW + XINT * (Y1 - YHIGH) / YINT
      YXF = .TRUE.
      GO TO 330
C
C     THE UPPER END OF THE LINES INTERSECTS THE TOP SIDE OF THE
C     RECTANGLE.
C
  310 X2 = X2 + XINT
  320 IF(X2 .GE. XHIGH)GO TO 340
      CALL PLOT(X2,YHIGH,1,0)
      X2 = X2 + XINT
  330 IF(X2 .GE. XHIGH)GO TO 340
      CALL PLOT(X2,YHIGH,0,0)
      GO TO 210
C
C     MOVE TO THE LOWER LEFT-HAND CORNER OF THE RECTANGLE.
C
  340 CALL PLOT(XLOW,YLOW,0,0)
      RETURN
C
      END
