	SUBROUTINE CHECK_GRAPHICS( status )

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
* check to see if there is a graphics output ready to recieve output
* (this routine assumes that PPLUS has been started)

* programmer - steve hankin
* NOAA/PMEL, Seattle, WA - Tropical Modeling and Analysis Program
* written for VAX computer under VMS operating system
*
* V200:  3/12/90 - written to permit metafile-only output
* v530: 1/00 *kob* - added info to check if animations are in progress
*       *acm* 3/12 cleanup ifdefs and unnecessary include files
*       *acm* 3/12 6D Ferret (common uses nferdims in tmap_dims.parm)

        IMPLICIT NONE
	include 'tmap_dims.parm'
	include 'ferret.parm'
	include 'errmsg.parm'
	include 'xprog_state.cmn'
	include	'gkscm1_inc.decl'	! with wsid
	include	'GKSCM1.INC'	! with wsid
	include	'pltcom_dat.decl'	! with gksopn
	include	'PLTCOM.DAT'	! with gksopn
	include 'xplot_setup.cmn'

* calling argument declarations
	INTEGER	status

* internal variable declarations
* ...

* only relevant for GKS output
	IF ( mode_gks ) THEN
	  IF ( .NOT.animate .AND. wsid.EQ.0 
     .              .AND. .NOT.mode_metafile ) GOTO 5100
	ENDIF

* success
	status = ferr_ok
	RETURN

* not output device is ready
 5000	RETURN
 5100	CALL ERRMSG( ferr_state_not_set, status,
     .		     'no graphical output'//pCR//
     .		     'Use SET WINDOW or SET MODE METAFILE', *5000 )
	END
