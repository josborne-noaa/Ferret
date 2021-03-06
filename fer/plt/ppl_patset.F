	SUBROUTINE PPL_PATSET( string )

* execute a PLOT+ PATSET command with the given string as argument

* programmer - steve hankin
* NOAA/PMEL, Seattle, WA - Tropical Modeling and Analysis Program

* V230: 11/92 - for color map protection during viewport manipulations
* V491: 12.98 - add PPL_PATSET() for pattern support *jd*

        IMPLICIT NONE
	include 'plot_setup.parm'
	include 'xrisc.cmn'		! to fix RISC FORTRAN bug

* calling argument declarations:
	CHARACTER*(*)	string

* internal variable declarations:

* initialize fixed length string for RISC (needed for DEC f77 v2.1)
	risc_buff = string
	len_rbuff = MIN( size_rbuff, LEN(string) )

* send the command to PLOT+  "PATSET [string]"
	CALL PPLCMD ( from, line, 0,
     .                'PATSET '//risc_buff(:len_rbuff), 1, 1 )

* always successful
        RETURN
	END
