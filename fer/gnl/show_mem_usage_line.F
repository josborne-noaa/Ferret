	SUBROUTINE SHOW_MEM_USAGE_LINE ( prefix, mem, do_words)

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
* display a single line about memory usage with nice formatting

* NOAA/PMEL, Seattle, WA - Tropical Modeling and Analysis Program
* written for VAX computer under VMS operating system

* V702  1/17 
* V751 *acm* 6/19 Issue 1903: memory set and reported in terms of bytes
*             First line may also show the total in words - if do_words flag.

        IMPLICIT NONE
	include 'tmap_dims.parm'
	include 'ferret.parm'
	include 'xprog_state.cmn'
	include 'xrisc.cmn'

* calling argument declarations:
	LOGICAL do_words
	INTEGER*8 mem
	CHARACTER*(*)	prefix

* internal variable declarations:
	INTEGER TM_LENSTR1, wlen, blen, i1, prelen
	CHARACTER TM_FMT*48,
     .		  word_unit*16, word_str*12,
     .		  byte_unit*3, byte_str*12

        IF (mem .GT. 1000000) THEN
           word_str = TM_FMT( mem/1.E6, 8, 12, wlen)
           word_unit = ' megawords'
           i1 = 10
        ELSE 
           word_str = TM_FMT( FLOAT(mem), 8, 12, wlen)
           word_unit = ' words'
           i1 = 6
        ENDIF


	IF (mem .EQ. 0) byte_unit = ' '
	CALL MEM_TO_BYTES (mem, byte_str, blen, byte_unit)

	prelen = TM_LENSTR1(prefix)
	
        IF (do_words) THEN
	   risc_buff = '    '//prefix(:prelen)//': '//
     .		    byte_str(:blen)//' '//byte_unit//'  ('//
     .		    word_str(:wlen)//word_unit(:i1)//')'
        ELSE
	   risc_buff = '    '//prefix(:prelen)//': '//
     .		    byte_str(:blen)//' '//byte_unit
	ENDIF

	CALL SPLIT_LIST(pttmode_explct, show_lun, risc_buff, 0)

	RETURN
	END
