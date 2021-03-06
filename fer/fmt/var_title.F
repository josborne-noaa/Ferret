	CHARACTER*(*) FUNCTION VAR_TITLE ( cx )

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
* return title for variable

* programmer - steve hankin
* NOAA/PMEL, Seattle, WA - Tropical Modeling and Analysis Program
* written for VAX computer under VMS operating system
*
* revision 0.0 - 6/4/86
* revision 1.0 - 1/6/87 - expression text found between commas for cat_expr_var
* revision 1.1 - 3/4/87 - semi-user vars added, expr disabled
* revision 1.2 - 3/23/87 - added new TMAP library: time axes, file var. names
* revision 2.0 - 5/11/87 - called with mr, only
* revision 2.1 - 3/10/88 - allowed for blank file variable titles,
*			   added cat_named_var
* V200:  6/20/89 - eliminated "named" variables
*		 - added user-defined variable titles
*	  1/3/90 - mr --> cx
*	 1/12/90 - allow unit changes by transforms
* V230:  3/3/92  - replace "D=#" with "D=name" in title
*       11/4/92 - expanded user variable name length
* V420: variable units may be modified by regrid transforms of the variable
* V500: 12/98 *sh* - added cat_const_var ... of the form "{1,3,5}"
* V500 *kob* 3/99- up VAR_CODE to 64 chars
* V530  8/00 *sh8 - added support for cat_string
* V552 *acm* 4/03- up VAR_CODE decl from 64 to 128 chars
* v553 *kob* 9/03- need to add buff, slen for assignment of VAR_TITLE - 
*                  g77 bug would cause crash when trying to prepend chars
*                  onto CHAR function variable 
* v554 *acm* 1/04 - add variable category cat_counter_var
* V600 8/05 *acm* - Add variable type attrib_val for definitions of the form
*                   varname.attname
* V600  4/06 *acm* - additional declarations found by Solaris compiler
* V601 10/06 *acm* fix bug 1442. plot and listing titles should show the 
*                  variable title, or if no title, the variable name.
* V698  3/16 *acm* Removed Philander-Seigel code including diagnostic 
*                  variables, pre-defined axes and grids, cat_calc_var.
* V698 3/16  *sh* added logic for cat_ef_time2d (ACTS_LIKE_FVAR)

        IMPLICIT NONE
        include	'tmap_dims.parm'
	include	'xdset_info.cmn_text'
	external xdset_info_data
	include 'xtm_grid.cmn_text'
	external xgt_grid_data
	include	'ferret.parm'
	include	'xvariables.cmn'
	include	'xcontext.cmn'
	include	'xalgebra.cmn'
        include 'errmsg.parm'

* calling argument declarations
	INTEGER	cx

* internal variable declarations
	LOGICAL 	UNIT_CHG_AX, NC_GET_ATTRIB, ACTS_LIKE_FVAR, got_it
	INTEGER 	TM_LENSTR1, cat, var, idim, tlen, llen, trans,
     .			uvar, item, start, end, slen, dset, varid,
     .                  attlen, attoutflag, status
        REAL            vals
	CHARACTER	AX_TITLE*32, VAR_CODE*128, SANITARY_VAR_CODE*128, 
     .                  TM_FMT*48, REPLACE_DEQ*180,   ! .GT. uvar_text_len
     .                  buff1*32, buff2*10, buff*2048, varname*128

* initialize
	var = cx_variable( cx )
	cat = cx_category( cx )

	IF     ( ACTS_LIKE_FVAR(cat) ) THEN
	   IF ( ds_var_title( var )(1:1) .NE. ' ' ) THEN
	      var_title = ds_var_title( var )
	   ELSE
              dset = cx_data_set(cx)
              IF (dset .NE. pdset_irrelevant .AND. 
     .            dset .NE. unspecified_int4) THEN
! is it in the linked-list for dset. If so get attr info, including original 
                 varname = SANITARY_VAR_CODE( cat, var )
                 CALL CD_GET_VAR_ID (dset, varname, varid, status)
                 got_it = status .EQ. ferr_ok .AND.
     .              NC_GET_ATTRIB (dset, varid, 'long_name',
     .             .TRUE., varname, 2048, attlen, attoutflag,
     .             buff, vals)
                 var_title = buff
                 IF (var_title .EQ. ' ') var_title = varname
              ELSE
                 var_title = VAR_CODE( cat, var )
!	         var_title = '"'//var_title(:TM_LENSTR1(var_title))//'"'
              ENDIF
	   ENDIF

	ELSEIF ( cat .EQ. cat_user_var  ) THEN

	   IF ( uvar_title( var ) .EQ. ' ' ) THEN
	      var_title = REPLACE_DEQ(
     .             uvar_text(var)(:TM_LENSTR1(uvar_text(var)) ))
	   ELSE
	      var_title = uvar_title( var )
	   ENDIF


	ELSEIF ( cat .EQ. cat_attrib_val  ) THEN

	   uvar = cx_variable(cx)
	   var_title = uvar_text(uvar)

	   IF ( uvar_title( uvar ) .EQ. ' ' ) THEN
	      var_title = REPLACE_DEQ(
     .             uvar_text(uvar)(:TM_LENSTR1(uvar_text(uvar)) ))
	   ENDIF

	ELSEIF ( cat .EQ. cat_pseudo_var ) THEN

	   var_title = alg_pvar(var)

	ELSEIF ( cat .EQ. cat_dummy_var ) THEN

	   var_title = 'dummy'

	ELSEIF ( cat .EQ. cat_temp_var ) THEN

	   var_title = 'temp var'

	ELSEIF ( cat .EQ. cat_constant ) THEN

	   var_title = 'constant'

	ELSEIF ( cat .EQ. cat_const_var ) THEN

	   uvar = cx_variable(cx)/1000
           item = cx_variable(cx) - 1000*uvar
           start = uvar_item_start( item, uvar )
           end   = uvar_item_end  ( item, uvar )
	   var_title = uvar_text(uvar)(start:end)

	ELSEIF ( cat .EQ. cat_string ) THEN

* determine the string to be stored
           uvar = cx_variable(cx)/1000
           item = cx_variable(cx) - 1000*uvar
           start = uvar_item_start( item, uvar )
           end   = uvar_item_end  ( item, uvar )
	   var_title = uvar_text(uvar)(start:end)

	ELSEIF ( cat .EQ. cat_counter_var ) THEN

	   var_title = 'counter'

	ELSE

	   var_title = 'bad_cat'

	ENDIF

* some transformations change the title
	IF ( UNIT_CHG_AX(cx,idim, trans) ) THEN
	   IF ( trans .EQ. punit_mod_loc ) THEN
	      buff1 = AX_TITLE( idim, cx_grid(cx), tlen )
	      buff2 = TM_FMT( cx_trans_arg(idim,cx), 4, 10, llen )
	      VAR_TITLE = buff1(:tlen)//' of '//buff2(:llen)//' in '//
     .		          VAR_TITLE
	   ELSEIF ( trans .EQ. punit_mod_variance ) THEN
	      buff = VAR_TITLE
	      slen = TM_LENSTR1(buff)		
	      VAR_TITLE = 'Variance of '//buff(:slen)
	   ELSEIF ( trans .EQ. punit_mod_npoints ) THEN
	      CONTINUE		! units take care of this
	   ENDIF	      
	ENDIF

	RETURN
	END
