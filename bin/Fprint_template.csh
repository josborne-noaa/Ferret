#! /bin/csh -f
# Fprint
# Script to translate metafiles generated by Ferret.  It runs either gksm2ps
# (on systems where Ferret uses xgks -- releases after Mar 1994), or mtt;
# please see the documentation on those.  It is intended to simplify sending
# plots to printers, to an output file only, or to a workstation screen.  This
# version translates to PostScript or Xwindow output.
#
# The script should work without modification to send output to the default
# printer at your site (whichever is specified in $PRINTER).
#
# The default behavior of this script is to translate metafiles to color PS (or
# grayscale) using line types appropriate for a monochrome PS printer.
#
# BUT the script should be modified to include the printers at your site.
# The section "MODIFY HERE" below contains case statements.  Each case is
# intended to be the name of a printer at your site, and the options set
# for that case determines the default action taken by the metafile translator.
# For example, whether lines are rendered in color or b&w.  The printers named
# in this template illustrate the use for supported device types.
#
# Examples of use:
#
# "Fprint metafile.plt" translates and prints 'metafile.plt' on $PRINTER
# "Fprint -P COLOR_PS metafile.plt" sends the plot to printer COLOR_PS
# "Fprint -o my_plot.ps metafile.plt" writes to a PS file named 'my_plot.ps'
# "Fprint -X metafile.plt" renders on the workstation screen.
#
# If you have questions please send email to davison@pmel.noaa.gov

# 12.15.94 Due to a bug in the DEC OSF lpr command, use of the -s (symbolic
# link, ie, don't copy the file -- used with large files) with the -r option
# (remove file after printing) cannot be done.  The file is deleted before it 
# printed.  Consequently for OSF machines, I have dropped the use of the -r 
# option and the print files will accumulate.


set err_txt = "no_err"
if ($#argv == 0 || "$argv" == "-h" || "$argv" == "-help") goto help

touch Fprint_output0.ps
rm -f Fprint_output*.ps

set output_args   	= " "
set output        	= "printer"
set printer_named	= 0
set translator_args  	= "-l cps -d cps"

set gksm2ps_files 	= ""
set mtt_files		= ""
set got_gksm2ps_files   = 0
set got_mtt_files	= 0		

set REMOVE = "-r"

# Pick off arguments til the end of argv
while ($#argv != 0)
   switch ($argv[1])
      case -P:
#        Send output to named printer  
	 shift argv      

	 set err_txt = "-P $argv[1]"
	 if (`echo $argv[1] | cut -c1` == "-") goto help
	 set output_args = "$output_args -P$argv[1]"
	 set output = "printer"

	 set fprinter = $argv[1]
	 set printer_named = 1
         shift argv

	 breaksw
      case -o:
#	 Output is to be directed to plot file and not printed
	 shift argv
      
 	 set err_txt = "-o $argv[1]"
	 if (`echo $argv[1] | cut -c1` == "-") goto help
	 set translator_args = "$translator_args -o $argv[1]"
	 set output = "file"
         shift argv

	 breaksw
      case -X:
#	 Output is to be directed to Xwindow
	 shift argv
 	 set translator_args = ""
	 set output = "Xwindow"

	 breaksw
      case -#:
#        Print N copies 
	 set output_args = "$output_args $argv[1]" 
	 shift argv      

	 set err_txt = "-# $argv[1]"
	 if (`echo $argv[1] | cut -c1` == "-") goto help
	 set output_args = "$output_args$argv[1]"
         shift argv

	 breaksw
      case -p:
#	 Page orientation: landscape or portrait
	 shift argv
	 
	 set err_txt = "-p $argv[1]"
	 if (`echo $argv[1] | cut -c1` == "-") goto help
	 if ($argv[1] != "landscape" && $argv[1] != "portrait") goto help

	 set translator_args = "$translator_args -p $argv[1]"
         shift argv

	 breaksw
      case -l:
#	 Line color: cps (color) or ps (b&w)
	 shift argv
      
	 set err_txt = "-l $argv[1]"
	 if (`echo $argv[1] | cut -c1` == "-") goto help
	 if ($argv[1] != "cps" && $argv[1] != "ps") goto help

	 set translator_args = "$translator_args -l $argv[1]"
         shift argv

	 breaksw
      case -d:
#	 Supported devices: cps (color PostScript) or phaser (TEK phaser ps)
	 shift argv
      
	 set err_txt = "-d $argv[1]"
	 if (`echo $argv[1] | cut -c1` == "-") goto help
	 if ($argv[1] != "cps" && $argv[1] != "phaser") goto help

	 set translator_args = "$translator_args -d $argv[1]"
         shift argv

	 breaksw
      case -R:
#	 Don't append to metafiles with date stamp when translation is complete
	 set translator_args = "$translator_args -R"
	 shift argv

	 breaksw
      case -C:
#	 Use CMYK color model 
	 set translator_args = "$translator_args -C"
	 shift argv

	 breaksw
      default:
	 # Everything else is passed to translator -- gotta be a file
	 if (! -e $argv[1]) then
	   echo "ERROR: $argv[1] is not a file name"
	   goto help
	 endif

	 head -n 1 $argv[1] | grep -s ^GKSM > /dev/null

	 if ($status == 0) then
	   set gksm2ps_files     = "$gksm2ps_files $argv[1]"
	   set got_gksm2ps_files = 1
	 else	 
	   set mtt_files         = "$mtt_files $argv[1]"
	   set got_mtt_files     = 1	 
	 endif

         shift argv
         breaksw
   endsw
end

if ($output != "printer" || ! $printer_named) goto xeq_translator

############################ MODIFY HERE ###################################

# Now set device characteristics for named printers
switch ($fprinter)
case COLOR_PS:
# If the printer is a color PS printer, use that device type
   set translator_args = "$translator_args -l cps -d cps"
   breaksw
case PHASER_PX_TRANSFER:
# BUT If the printer is a PHASER PX with transfer sheets, type is "phaser"
   set translator_args = "$translator_args -l cps -d phaser"
   breaksw
# The following example printers take the default options mentioned above.
case MONOCHROME_PS1:
   breaksw
case MONOCHROME_PS2:
   breaksw
case MONOCHROME_PS3:
   breaksw
default:
# The named printer is not a valid choice:
# This is the sort of message I anticipate the user getting if one names an
# unsupported printer:
#
#   echo -n "'${fprinter}' is not a valid printer."
#   if ($?PRINTER) then
#     echo " The default printer is $PRINTER."
#   else
#     echo " "
#   endif
#   echo " Available printers are COLOR_PS, PHASER_PX_TRANSFER,"
#   echo " MONOCHROME_PS1, MONOCHROME_PS2, and MONOCHROME_PS3"
#
# For now a user gets this message:
   echo " "
   echo " The Fprint script has not been set up to use the -P option"
   echo " yet -- it should work with the default printer."
   echo " "
   exit
endsw

##################### END OF "MODIFY HERE" SECTION ##########################

# Now process the metafile(s) and print the plot file if appropriate
xeq_translator:
if (`uname -s` == "OSF1") set REMOVE = ""
switch ($output)
case printer:
   if ($got_gksm2ps_files) then
      gksm2ps -o Fprint_output1$$.ps $translator_args $gksm2ps_files
      if (-e Fprint_output1$$.ps) then
         lpr -s ${REMOVE} $output_args ./Fprint_output1$$.ps
      endif
   endif

   if ($got_mtt_files) then
      mtt -o Fprint_output2$$.ps $translator_args $mtt_files
      if (-e Fprint_output2$$.ps) then
         lpr -s ${REMOVE} $output_args ./Fprint_output2$$.ps
      endif
   endif

   breaksw
case file:
   if ($got_gksm2ps_files) gksm2ps $translator_args $gksm2ps_files 
   if ($got_mtt_files)    mtt     $translator_args $mtt_files 
   breaksw
case Xwindow:
   if ($got_gksm2ps_files) gksm2ps -X $gksm2ps_files 
   if ($got_mtt_files) mtt $mtt_files

   breaksw
endsw
exit

help:
   if ("$err_txt" != "no_err") echo "ERROR: You made a syntax error near $err_txt"
   echo "Script to translate Ferret's graphics metafile(s) to PostScript"
   echo "usage: Fprint [-P printer || -o file_name || -X]"
   echo "              [-p landscape || portrait] [-# <number of copies>]"
   echo "              [-l ps || cps] [-R] metafile(s)"
   echo " "
   echo "   -P: send PostScript output to the named printer"
   echo "   -o: send PostScript output to a file and don't print the plots"
   echo "   -X: send the plots to your X Window for preview"
   echo "   -p: page orientation, landscape or portrait"
   echo "   -#: print more than one copy of the plots"
   echo "   -l: line styles, ps == monochrome, cps == color"
   echo "   -R: do not rename files with a date stamp appended (default is to stamp)"
   echo "   -C: Output a CMYK postscript file (default is RGB)" 
   echo "Examples: "
   echo "    Fprint metafile.plt*"
   echo "    Fprint -P our_color_printer -l cps -# 10 metafile.plt*"
   echo "    Fprint -p portrait -R metafile.plt.~2~"
   exit
