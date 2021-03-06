	SUBROUTINE ASSIGN_MR_CX( cx, mr )

*  This software was developed by the Thermal Modeling and Analysis
*  Project(TMAP) of the National Oceanographic and Atmospheric
*  Administration''s (NOAA) Pacific Marine Environmental Lab(PMEL),
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
* fill a slot in the memory variable table with context information

* programmer - steve hankin
* NOAA/PMEL, Seattle, WA - Tropical Modeling and Analysis Program

* V200:  6/26/89 - extracted from ASSIGN_VARIABLE
* V530:  8/00 *sh* save data type, too
* V530:  6/01 *sh* save the delta value, too
*        2/12 *kms* Add E and F dimensions (use nferdims in tmap_dims.parm)
* V685+ 10/13 *sh* added auxiliary regridding "aux" variables
* V692 7/14 *acm* ticket 2183: handle @WGT transform as for integrals
* V720 5/17 *sh* code in proper handling od DSG ww constraints

        IMPLICIT NONE
        include 'tmap_dims.parm'
	include 'ferret.parm'
	include 'xvariables.cmn'
	include 'xcontext.cmn'

* calling argument declarations:
	INTEGER		cx, mr

* internal variable declarations:
	LOGICAL		TM_ITSA_DSG, its_dsg
	INTEGER		idim, trans, grid
	REAL*8		TM_WORLD

* initialize
	grid = cx_grid( cx ) 
	its_dsg = TM_ITSA_DSG(grid)

* background info
	mr_data_set ( mr )	= cx_data_set( cx )
	mr_category ( mr )	= cx_category( cx )
	mr_variable ( mr )	= cx_variable( cx )
	mr_type     ( mr )	= cx_type    ( cx )
	mr_grid     ( mr )	= grid
	mr_bad_data ( mr )	= cx_bad_data( cx )
	mr_unstand_grid( mr )   = cx_unstand_grid( cx )
	mr_naux     ( mr )      = cx_naux     ( cx )

* region, transformations and regridding transforms
	DO 100 idim = 1,nferdims
	   trans = cx_trans( idim, cx )
	   mr_trans  ( idim, mr )   = trans
	   mr_lo_ss  ( mr, idim )   = cx_lo_ss  ( cx, idim )
	   mr_hi_ss  ( mr, idim )   = cx_hi_ss  ( cx, idim )
	   mr_delta  ( idim, mr )   = cx_delta  ( idim, cx )
	   mr_aux_var( idim, mr )   = cx_aux_var( idim, cx )
	   mr_aux_cat( idim, mr )   = cx_aux_cat( idim, cx )
	   mr_trans_arg(idim, mr)   = cx_trans_arg(idim, cx)
	   mr_regrid_trans( idim, mr ) = cx_regrid_trans( idim, cx )

* round out to world coordinate box edges except in some special cases:
*   i) indefinite integrals (since they depend on exact integration limits)
*  ii) transforms (except MIN and MAX) that reduce to a point
* iii) user-defined variables that are based on transformed quantities
*      (e.g. DEFINE UAVE = U[K=1:3@AVE])

	   IF ( its_dsg                        .OR.
     .		(trans .EQ. trans_integ_indef) .OR.
     .          (trans .EQ. trans_avg_wgt)     .OR.
     .          (trans .EQ. trans_4d_avg_wgt)  .OR.
     .          ( (trans .GT. trans_compress_code) .AND.
     .            (trans .NE. trans_max)           .AND.
     .            (trans .NE. trans_min) )     .OR.
     .          (cx_lo_ss(cx,idim) .EQ. unspecified_int4) ) THEN
* ... catalog with exact world coordinate limits
	      mr_lo_ww( idim, mr ) = cx_lo_ww( idim, cx )
	      mr_hi_ww( idim, mr ) = cx_hi_ww( idim, cx )
	   ELSE
* ... round out limits out to indicate full span of end grid boxes
	      mr_lo_ww(idim, mr) = TM_WORLD( cx_lo_ss(cx,idim),
     .					     grid,
     .					     idim, box_lo_lim	)
	      mr_hi_ww(idim, mr) = TM_WORLD( cx_hi_ss(cx,idim),
     .					     grid,
     .					     idim, box_hi_lim	)
	   ENDIF
 100	CONTINUE

	RETURN
	END
