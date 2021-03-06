      SUBROUTINE INHERIT_ATTRS (varname1, varname2, title, units, status)
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

* Get all attributes from varname1, a variable in dataset dset1, and assign to the 
* variable in varname2, dataset dset2.  dset2 has been determined in xeq_set.F
* V600  4/06 *acm*   attribute handling
* V600  4/06 *acm* - additional declarations found by Solaris compiler
* V670  2/11 *acm*   Fixes for inheriting attributes.
*       *acm* 3/12 6D Ferret (common uses nferdims in tmap_dims.parm)
* V698  2/16 *acm* For ticket 2352: variables defined with LET/D are
*                  added to that dataset in the attribute structure.
* v71   7/16 *acm* Fix ticket 2447: special handling of missing-value flags
*                  when inheriting all attributes from one variable to another.
* V720 *acm* 5/17 Implement specific calls in place of CD_GET_VAR_INFO
* V740 *acm* 2/18 Issue 966: LET/LIKE= For inheriting attributes, want to
*                 apply the user's title and units if given. Also do not 
*                 inherit scale_factor or add_offset attributes. 

      IMPLICIT NONE
      INCLUDE 'tmap_dims.parm'
      INCLUDE 'ferret.parm'
      INCLUDE 'errmsg.parm'      
      INCLUDE 'xprog_state.cmn'
      INCLUDE 'xvariables.cmn'
      INCLUDE 'xcontext.cmn'

* Argument declarations
      CHARACTER varname1*(*), varname2*(*), title*(*), units*(*)
      INTEGER status

* Local variable declarations
      LOGICAL CD_ISIT_COORDVAR, iskip
      INTEGER TM_LENSTR, STR_SAME, slen, tlen, dset1, dset2, 
     .  varid1, varid2, nvatts1, nvatts2,
     .  iatt, first_quote, next_quote, dot, mr, cx, 
     .  cat, iflag, attnum, ltitle, lunits
      CHARACTER*128 attname, buff1, buff2

* Check that neither buffer contains varname.attname (If it is in 
* quotations then the dot is part of the variable name.)

      tlen = TM_LENSTR(varname1) 
      first_quote = INDEX(varname1(1:tlen), "'" )
      next_quote = INDEX(varname1(2:tlen), "'" )

      ltitle = TM_LENSTR(title)
      lunits = TM_LENSTR(units)

      IF (INDEX(varname1,'.') .NE. 0 ) THEN
         dot = INDEX(varname1,'.')
         IF (dot .GT. first_quote .AND. dot .LT. next_quote) GOTO 5010
      ENDIF

* and now for varname2
      tlen = TM_LENSTR(varname2) 

      first_quote = INDEX(varname2(1:tlen), "'" )
      next_quote = INDEX(varname2(2:tlen), "'" )

      IF (INDEX(varname2,'.') .NE. 0 ) THEN
         dot = INDEX(varname2,'.')
         IF (dot .GT. first_quote .AND. dot .LT. next_quote) GOTO 5010
      ENDIF

* Do the varnames contain dataset specifications?
* evaluate the context without computing the expression to get the dataset

      CALL GET_NEW_CX( cx_last, cx_cmnd, .TRUE., status )
      IF ( status .NE. ferr_ok ) GOTO 5000
 
      CALL EVAL_CONTEXT ( cx_cmnd, varname1, status )
      IF ( status .NE. ferr_ok ) GOTO 5000

      mr = is_mr( 1 )
      cx = is_cx( 1 )

      dset1 = cx_data_set(cx) 
      IF (dset1 .EQ. pdset_irrelevant) dset1 = cx_data_set(cx_last) 

      cat = cx_category(cx)
      IF (cat .EQ. cat_user_var) dset1 = pdset_uvars

      CALL GET_NEW_CX( cx_last, cx_cmnd, .TRUE., status )
      IF ( status .NE. ferr_ok ) GOTO 5000
 
      CALL EVAL_CONTEXT ( cx_cmnd, varname2, status )
      IF ( status .NE. ferr_ok ) GOTO 5000

      mr = is_mr( 1 )
      cx = is_cx( 1 )

      dset2 = cx_data_set(cx) 
      IF (dset2 .EQ. pdset_irrelevant) dset2 = cx_data_set(cx_last) 

      cat = cx_category(cx)

* Get varid for each variable.
      CALL CD_GET_VAR_ID (dset1, varname1, varid1, status)
      IF (status .NE. ferr_ok) GOTO 5050
      CALL CD_GET_VAR_ID (dset2, varname2, varid2, status)
      IF (status .NE. ferr_ok) THEN
         IF (cat .EQ. cat_user_var) dset2 = pdset_uvars 
	 CALL CD_GET_VAR_ID (dset2, varname2, varid2, status)
      ENDIF
      IF (status .NE. ferr_ok) GOTO 5050

* Get number of attributes for variables

      IF (CD_ISIT_COORDVAR(dset1, varid1, varname1, status)) GOTO 5020
      CALL CD_GET_VAR_NATTS (dset1, varid1, varname1, nvatts1, status)

      IF (CD_ISIT_COORDVAR(dset2, varid2, varname2, status)) GOTO 5020
      CALL CD_GET_VAR_NATTS (dset2, varid2, varname2, nvatts2, status)

* Remove attributes from variable 2
* When an attribute is deleted, the following attributes move forward
* so need to keep asking for the first attribute not skipped
* Do not change missing_value or _FillValue. Also do not inherit add_offset
* or scale_factor attributes. If title or units are sent in, we'll use those
* rather than inheriting them.

      attnum = 1
      DO 100 iatt = 1, nvatts2
         iskip = .FALSE.
         CALL CD_GET_VAR_ATT_NAME (dset2, varid2, attnum, attname, status)

         IF ( STR_SAME(attname, 'missing_value')  .EQ. 0) iskip = .TRUE.
         IF ( STR_SAME(attname, '_FillValue') .EQ. 0 ) iskip = .TRUE.
         IF ( STR_SAME(attname, 'scale_factor') .EQ. 0 ) iskip = .TRUE.
         IF ( STR_SAME(attname, 'add_offset') .EQ. 0 ) iskip = .TRUE.
         IF ( STR_SAME(attname, 'long_name') .EQ. 0 .AND. ltitle.GT.0) iskip = .TRUE.
         IF ( STR_SAME(attname, 'units') .EQ. 0 .AND. lunits.GT.0) iskip = .TRUE.

	 IF (iskip) THEN
            attnum = attnum + 1
         ELSE
            CALL CD_DELETE_ATTRIBUTE (dset2, varid2, attname, status)
            IF (status .NE. ferr_ok) GOTO 5030
         ENDIF

 100  CONTINUE

* Get attribute information from variable 1 and put onto variable 2.
* Do this in the c library so we dont have to define a fixed string for
* string type attributes.

      iflag = 1
      DO 200 iatt = 1, nvatts1
         CALL CD_GET_VAR_ATT_NAME (dset1, varid1, iatt, attname, status)

         iskip = .FALSE.
         IF ( STR_SAME(attname, 'missing_value')  .EQ. 0) cycle
         IF ( STR_SAME(attname, '_FillValue') .EQ. 0 ) cycle
         IF ( STR_SAME(attname, 'scale_factor') .EQ. 0 ) cycle
         IF ( STR_SAME(attname, 'add_offset') .EQ. 0 ) cycle
         IF ( STR_SAME(attname, 'long_name') .EQ. 0 .AND. ltitle.GT.0) cycle
         IF ( STR_SAME(attname, 'units') .EQ. 0 .AND. lunits.GT.0) cycle
	 IF (iskip) cycle
	 CALL CD_TRANSFER_ATTRIBUTE (dset1, varid1, iatt, 
     .        dset2, varid2, status)
	 IF (status .NE. ferr_ok) GOTO 5040
	 CALL CD_SET_ATT_FLAG (dset2, varid2, attname, iflag, status)
	 IF (status .NE. ferr_ok) GOTO 5040

 200  CONTINUE

* Update attribute information used by plotting etc (ds_units, ...)

        CALL UPDATE_ATTRIBUTES (dset2, varname2, varid2, status)
        IF (status .NE. ferr_ok) GOTO 5040

 5000 RETURN

 5010 CALL ERRMSG( ferr_invalid_command, status,
     .  'Use SET ATT/LIKE=var2 var1 without attribute names', *5000 )

 5020 CALL ERRMSG (ferr_invalid_command, status,
     . 'Cannot inherit attributes to/from coordinate variables', *5000)

 5030 buff2 = varname2
      CALL ERRMSG (ferr_internal, status,
     . 'Error removing attributes from '//buff2(:tlen), *5000)

 5040  slen = TM_LENSTR(varname1)
       buff1 = varname1
       CALL ERRMSG (ferr_internal, status,
     . 'Error transferring attributes from '//buff1(:slen)//' to '//
     .  buff2(:tlen), *5000)

 5050  slen = TM_LENSTR(varname1)
       buff1 = varname1
       CALL ERRMSG (ferr_var_not_in_set, status,
     . varname1(:slen),*5000)

 5060  slen = TM_LENSTR(varname1)
       buff1 = varname1
       CALL ERRMSG (ferr_var_not_in_set, status,
     . varname1(:slen),*5000)

      END
