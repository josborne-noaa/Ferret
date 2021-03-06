	SUBROUTINE SECS_TO_YMDHMS ( num_secs,
     .				    yr, mon, day, hr, min, sec )

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
* Will break secs since 01-JAN-0000 00:00:00 into separate yr,mo,day,hr,min,sec
* fields

* V530 *sh* 1/02 - based upon tm_secs_to_date.F
* V6.31 *acm* 11/09 Simplify the logic which decides what month/day it is
*             as is already done in tm_secs_to_date.

        IMPLICIT NONE
* Argument declarations
	INTEGER	yr, mon, day, hr, min
	REAL	sec
	REAL*8	num_secs
	
*
* Local Definition
	INTEGER		month_by_day(365), leapadj, cent_cnt,
     .			year_cnt, cent4_cnt, year4_cnt, tot_days,
     .			tmp_days, days_before_month(12), ge59
	REAL*8		secs_in_minute, secs_in_hour, secs_in_day,
     .			secs_in_year, secs_in_4years, secs_in_cent,
     .			secs_in_4cents, total_secs

	PARAMETER	(secs_in_minute	 = 60.,
     .			 secs_in_hour	 = secs_in_minute*60.,
     .			 secs_in_day	 = secs_in_hour*24.,
     .			 secs_in_year	 = secs_in_day*365.,
     .			 secs_in_4years	 = secs_in_day*(3*365.+366.),
     .			 secs_in_cent    = secs_in_day*(76*365.+24*366.),
     .			 secs_in_4cents  = 4*secs_in_cent+secs_in_day)

	DATA month_by_day /31*01, 28*02, 31*03, 30*04, 31*05, 30*06,
     .			   31*07, 31*08, 30*09, 31*10, 30*11, 31*12/
	DATA days_before_month	/   0,  31,  59,  90, 120, 151,
     .				  181, 212, 243, 273, 304, 334/

* trap invalid input
	IF ( num_secs .LT. 0 ) THEN
	   yr = 0
	   mon = 1
	   day = 1
	   hr = 0
	   min = 0
	   sec = 0.0
	   RETURN
	ENDIF

* Initialize
	total_secs = num_secs

* Subtract year 0 off (it's a leap year)
	total_secs = total_secs - secs_in_year - secs_in_day

* make sure we aren't working in year 0
	IF (total_secs .GE. 0) THEN

* Decide which century it is
	  cent4_cnt = INT(total_secs/secs_in_4cents)
	  total_secs = total_secs - cent4_cnt*secs_in_4cents
	  cent_cnt = INT(total_secs/secs_in_cent)
* Dec 31 on leap century test (years 400,800,1200...)
	  IF (cent_cnt .EQ. 4                         .AND.
     .	      total_secs .GE. cent4_cnt-secs_in_day)   cent_cnt = 3
	  total_secs = total_secs - cent_cnt*secs_in_cent
	  yr = 400*cent4_cnt + 100*cent_cnt

* Decide what year it is exactly (1 year for year 0)
	  year4_cnt = INT(total_secs/secs_in_4years)
	  total_secs = total_secs - year4_cnt*secs_in_4years
	  year_cnt = INT(total_secs/secs_in_year)
* Dec 31 on leap year test (years 0,4,8,12...)
	  IF (year_cnt .EQ. 4                         .AND.
     .	      total_secs .GE. secs_in_4years-secs_in_day)   year_cnt = 3
	  total_secs = total_secs - year_cnt*secs_in_year
	  yr = yr + 4*year4_cnt + year_cnt + 1

	ELSE
* Year 0 stuff
	  yr = 0
	  total_secs = total_secs + secs_in_year + secs_in_day
	ENDIF

* Is this a leap year? (every 4th century is, otherwise century isn't)
	leapadj = 0
	IF (MOD(yr,400) .EQ. 0) THEN
	  leapadj = 1
	ELSE IF (MOD(yr,4) .EQ. 0 .AND. MOD(yr,100) .NE. 0) THEN
	  leapadj = 1
	ENDIF

* How many days into year is this
	tot_days = INT(total_secs/secs_in_day)
	total_secs = total_secs - tot_days*secs_in_day

* Decide what month/day it is

	ge59 = 0
	IF (tot_days .GE. 59) ge59 = 1
	tmp_days = tot_days - leapadj* ge59

	IF (tmp_days .LT. 0) STOP 'negative subscript in TM_SECS_TO_DATE'
	mon = month_by_day(tmp_days+1)

	leapadj = INT(mon/12. +.75)*leapadj
	day = tot_days - (days_before_month(mon)+leapadj) + 1

* Calculate number of hours
	hr = INT(total_secs/secs_in_hour)
* Subtract seconds for number of hours
	total_secs = total_secs - secs_in_hour*(hr)
* Calculate number of minutes
	min = INT(total_secs/secs_in_minute)
* Subtract seconds for number of minutes
	total_secs = total_secs - secs_in_minute*(min)
* Calculate number of seconds
	sec = total_secs

* finished
9990	RETURN
	END
