      SUBROUTINE CD_GET_VAR_OUTTYPE (dset, varid, outtype, status)

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
* Read the linked list structure for netcdf variable information: 
* given dset and variable id return its output type

* Programmer Ansley Manke
* NOAA/PMEL, Seattle, WA - TMAP

* V600 2/06 *acm* Attribute control.
* V602 2/07 *acm* Fix bug 1492, changing attributes of coordinate variables 
* V62+ 5/09 *acm* Fix bug 1664, initialize outtype = 0 so we dont get an
*                 incorrect type for user variables.
* V6.74 3/12 *acm* cleanup ifdefs and unnecessary include files

* include files
#include "gt_lib.parm"
      INCLUDE "tmap_errors.parm"

* Argument declarations

      INTEGER dset, varid, outtype

* Internal declarations

      INCLUDE 'netcdf.inc'

      INTEGER NCF_GET_VAR_OUTTYPE, dset_num, status

* Initialize

      outtype = 0

      dset_num = dset
      IF (dset_num .LT. -2) dset_num = -2
      status = NCF_GET_VAR_OUTTYPE(dset_num, varid, outtype)

 5000 RETURN
      END
