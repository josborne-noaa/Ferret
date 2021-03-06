c
c	vector
C** 
C**    @(#)VECTOR.INC	1.1    3/10/88
C**
C**
C***********************************************************************
C**
C**                 PLOT+ Scientific Graphics System
C**
C***********************************************************************
C**
C**
C ** v5.81 *acm* lengthen strings containing format to 40 characters.
c
	COMMON/VECTOR/VLEN,VUSRLN,VXLOC,VYLOC,VPOS,VMINLN,
     *	ARMAX,ARMIN,HFACT,VSKPX,VSKPY,DENSITY,NEED_COS,TRNSPZ,
     *	VAUTO,VUSER,VKEY,VFRMT
c
c	vlen	vector length (inches) used for key length
c	vusrln	user unit value for vlen vector
c	vauto	logical if true auto scale
c	vxloc	x location for key
c	vyloc	y location for key
c	vuser	logical if true user units for position
c	vkey	logical if true draw the key
c	vpos	justification for key
c	vfrmt	format to use for key label
c	vskpx	skip x
c	vskpy	skip y
c	vminln	minimum vector size
c	armax	size for maximum head size
c	armin	size for minimum head size
c	hfact	size factor for head
c       density density parameter for flowlines
c       need_cos flag for geographical correction 
c       transpz flag for transpose (needed for geographical cosine correction)
c
c*******************************************************************
