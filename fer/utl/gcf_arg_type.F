	INTEGER FUNCTION GCF_ARG_TYPE( gcfcn, iarg )

* return the argument type required for this argument

* V500:  1/99
*       *acm* 3/12 6D Ferret (common uses nferdims in tmap_dims.parm)

        IMPLICIT NONE
* calling argument declarations
	INTEGER		gcfcn, iarg

* internal variable declarations
	INTEGER		iptr
	INTEGER efcn_get_arg_type

	include	'tmap_dims.parm'
	include 'ferret.parm'
	include 'grid_chg_fcns.parm'   ! for place-holder behavior
	include 'xgrid_chg_fcns.cmn'


	IF ( gcfcn .GT. gfcn_num_internal ) THEN
* ... external function
	   GCF_ARG_TYPE = efcn_get_arg_type(gcfcn, iarg)

	ELSE
* ... internal grid-changing function
	   iptr = gfcn_arg_ptr(gcfcn)
	   GCF_ARG_TYPE = gfcn_arg_type(iptr+iarg-1)

	ENDIF

	RETURN
	END
