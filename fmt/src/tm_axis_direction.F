	INTEGER FUNCTION TM_AXIS_DIRECTION( iaxis )

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
* decode the "line_direction" to a simple axis

* NOAA/PMEL, Seattle, WA - Tropical Modeling and Analysis Program
* written for VAX computer under VMS operating system

* revision 0.0 3/92 for TMAP library
* 10/96 *kob* - Linux port - had to move variable assignments off of
*		declaration line.
* v553 6/03 *acm*  cd_read_1_axis may assign 'XX' or 'YY' to line_direction
*                  based on value of AXIS attribute. Or DEFINE_AXIS may 
*                  use these for non-lat/lon axes. Assign the axis the 
*                  corresponding direction.
* V674 2/12 *acm* 6D Ferret: use nferdims rather than 4 for dimension indexing
* V710 9/16 *acm* Use ww_dim_name from xtext_info.cmn
* V710 1/17 *acm* Recognize generic FF axis direction (FI is forecast-time specific)

        include 'tmap_dims.parm'
#include "tmap_dset.parm"
#include "gt_lib.parm"
        include 'xtm_grid.cmn_text'
	include 'xtext_info.cmn'  ! with ww_dim_name

* calling argument declarations:
      INTEGER  iaxis

* internal variable declarations:
* *kob* explicit definitions not allowed on decl line in linux...
*       moved it to parameter line 10/96
      INTEGER STR_UPCASE, idim, istat
      CHARACTER*1 c1
      CHARACTER*2 orient

* initialize
      orient = line_direction(iaxis)

* check the obvious
      DO 100 idim = 1, nferdims
         IF ( orient .EQ. axis_orients(idim) ) THEN
            TM_AXIS_DIRECTION = idim
            RETURN
         ENDIF
 100  CONTINUE

* other previously determined orientations
      IF ( orient .EQ. 'UD' ) THEN
         TM_AXIS_DIRECTION = z_dim
      ELSEIF (orient .EQ. 'EW' ) THEN
         TM_AXIS_DIRECTION = x_dim
      ELSEIF (orient .EQ. 'XX' ) THEN
         TM_AXIS_DIRECTION = x_dim
      ELSEIF (orient .EQ. 'YY' ) THEN
         TM_AXIS_DIRECTION = y_dim
      ELSEIF (orient .EQ. 'TT' ) THEN
         TM_AXIS_DIRECTION = t_dim
      ELSEIF (orient .EQ. 'FF' ) THEN
         TM_AXIS_DIRECTION = f_dim
      ELSE
         TM_AXIS_DIRECTION = 0
      ENDIF

* last ditch attempt based on axis name and units
* ACM V6.8: Dont do this! Sets ETA to an E axis for instance.
* See ticket 1955.

c      IF ( TM_AXIS_DIRECTION .EQ. 0 ) THEN
c         istat = STR_UPCASE( c1, line_name(iaxis)(1:1) )
c         DO 200 idim = 1, nferdims
c 200     IF ( c1 .EQ. ww_dim_name(idim) ) TM_AXIS_DIRECTION = idim
c      ENDIF

      RETURN
      END
