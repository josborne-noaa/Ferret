/*
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
*/



/*
*	PROGRAM FERRET - C version of MAIN program with reconfigurable memory
*
* TMAP interactive data analysis program
*
* programmer - steve hankin
* NOAA/PMEL, Seattle, WA - Tropical Modeling and Analysis Program
*/

/*
* FERRET program history:
* initially tailored to output format and content of the Philander/Seigel 
* model from GFDL
* revision 0.0  - 4/3/86
* revision 1.0 - 11/17/86 - first "official" release
* revision 2.0 - 10/23/87 - "official" release
* revision 2.01(temporary) - 10/23/87 - smaller memory size, bug fixes,
*			2 typos in XVARIABLES_DATA, ^C added, ZT planes added
* revision 2.02 - ?????
* revision 2.10 - 5/6/88 - "final" release - /NODEBUG version
* FERRET 1.00     - 6/10/88 - rename of GFDL 2.10
* FERRET 1.10     -  8/2/88 - numerous bug fixes and enhancements
* FERRET 1.20     - 2/17/89 - numerous bug fixes and enhancements
* FERRET 1.21     - 4/19/89 - minor bug fixes
* FERRET 2.00	  - 5/??/89 - internal re-write: 4D grids and "object oriented"
*			      transformations
* FERRET 3.00     - 1/29/93 - revision 2.2-->2.3 changes became so extensive
*                             and prolonged it made sense to rename to V3.0
* FERRET 3.10     - 4/94 - official release using XGKS
* FERRET 3.11     - 5/94 - added FILE/ORDER=/FORMAT=STREAM
* FERRET 3.12     - 5/94 - restructured to be "dynamic memory" (C main routine)
*			   former MAIN became FERRET_DISPATCH routine
* FERRET 3.13     - 7/94 - relink of Solaris version
*                          (using IBM-portable TMAP libs)
*|*|*|*|*|*|*|*|*|*|*|*|
*
*  revision history for MAIN program unit:
*     11/16/94 - changed to a c version of ferret_dispatch_c
* FERRET 4.0     - 7/94 - using a C main program with dynamic memory
*                - 6/95 - *kob* had to add ifdef checks for 
*		  	  NO_ENTRY_NAME_UNDERSCORES for hp port, as hp
*			  doesnt need trailing underscores for c/fortran 
*			  compatibility
*    3/5/97 *sh* changes to incorporate "-batch" qualifier
* Linux Port 5/97 *kob*   Using NAG f90 for linux, we first have to 
*                         call f90_io_init() to set up lun's etc, and then
*                         call f90_io_finish() after we are done 
*                         to flush buffers,etc
*    7/25/97 *js* changes to incorporate output file for -batch
*    8/97 *kob* - had to add another ifdef check for entry_name_underscores
*              around call to curv_coord_sub
*
*    10/16/97 *kob* - Combining non-gui main program w/ gui main program so that
*                     there needs only be one main program.  added an ifdef 
*                     LINK_GUI_AS_MAIN around the gui-exclusive code
*    10.28.98 *js* Added -secure option
*     3.12.99 *js* Moved GUI code into new module. Also, cleaned up
*                   numerous LINK_GUI_AS_MAIN ifdefs. Also added new gui_get_memory
*                   function since the GUI uses a global memory variable ptr and
*                   the non-GUI uses a stack ptr that was #ifdef'd.
*     9/18/01 *acm* Add ppl memory buffer ppl_memory, defined in ferret_shared_buffer.h
*                  along with Ferret *memory.  Initialize its size, and call
*                  save_ppl_memory_size so the size is available via common to 
*                  Fortran routines.  New declaration of save_ppl_memory_size 
*                  in ferret.h
*    10/19/01 *kob* fix output formatting bug which was printing memory size
*                   (in Mwords) divided by float 1.E6 as a decimal, rather than
*                   a float value - changed in three places
*     8/22/03 *acm* New -script command-line switch: run the named script and exit.
*                   This mode also sets -nojnl and -server, as well as the new
*                   -noverify switch.  It also supresses the banner lines.
*     3/ 1/04 *acm* For -script startup option, list the script arguments in the
*                   string script_args separated by blanks not commas.  If commas, 
*                   then could not use commas within an argument, e.g. a region 
*                   specification.
*     3/24/04 *acm* The -script switch interacts with any SET MEMORY commands
*                   within the script.  Set a flag when this occurs, so that
*                   ferret_dispatch can be called correctly after the memory reset, 
*                   continuing to execute the commands from the script
*     4/28/06 *acm* When a script specified with -script has a pathname, we need
*                   quotes around it.  The syntax for putting together the command string
*                   GO "/pathname/scriptname.jnl"; EXIT/PROGRAM was missing the closing quote
*     5/19/06 *acm* Fix bug 1662: If SET MEM command is in the .ferret startup file got lots
*                   of messages.fix as for the SET MEM in a script run via the  -script startup.
*                   with a setting of script_resetmem.
*
* *kob* 10/03 v553 - gcc v3.x needs wchar.h included
* *acm*  9/06 v600 - add stdlib.h wherever there is stdio.h for altix build
* *acm*  2/07 v602 - add check for overflow on large memory requests (as in xeq_set.F, bug 1438)
* *kms*  8/10 v664 - Catch SIGILL, SIGFPE, and SIGSEGV and exit gracefully with a stderr message for LAS
*                    Just re-enter the ferret_dispatch loop if it returns with sBuffer->flags[FRTN_ACTION]
*                    set to FACTN_NO_ACTION (for EXIT/TOPYTHON when not under pfyrret)
* *kms*  2/11      - Make mem_size a size_t variable - malloc's expected variable type.
*                    Change resize requests to pass mem_blk_size (an int) instead of
*                    mem_size (a size_t) in sBuffer->flags[FRTN_IDATA1]
* *acm*  1/12      - Ferret 6.8 ifdef for double-precision ferret, see the
*                    definition of macro DFTYPE in ferret.h. ppl_memory remains float.
* *kms*  2/16      - only catch/handle crash signals and exit gracefully if NDEBUG is defined;
*                    if debug build, let it crash
* *sh*  2/17       - removed global "memory" -- now 1 malloc per Ferret var
* *acm* 5/17       - restore -memsize switch to make the initial SET MEMORY setting
* *acm* 12/18      -  Issue 1803, new command-line switch -verify for set mode ver:always behavior
* *kms*  7/19      - if ./.ferret exists, use it instead of $HOME/.ferret
*/

#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <signal.h>
#include "ferret.h"
#include "FerMem.h"
#include "ferret_shared_buffer.h"
#include "pplmem.h"
#include "xgks.h"

/* Instantiate the globals in ferret_shared_buffer */
smPtr sBuffer;
float *ppl_memory;

int its_script;
char script_args[2048];
int arg_pos;

static void command_line_run();

static void help_text(void)
{
  printf(
	 "Usage:  ferret [-memsize Mflts] [-batch [outfile]] [-server] [-secure] [-gif] [-unmapped] [-help] [-nojnl] [-noverify]  [-verify] [-script [args]]\n"
         "   -memsize:  specify the memory cache size (default 25.6) in mega (10^6) flts where a flt\n"
         "              is 8 bytes in double-precision Ferret\n"
         "   -batch:  output directly to metafile \"outfile\" w/out X windows\n"
         "   -unmapped:  use invisible output windows (superceded by -batch)\n"
         "   -gif:  output to GIF file w/o X windows only w/ FRAME command\n"
         "   -secure:  run securely -- don't allow system commands\n"
         "   -server:  run in server mode -- don't stop on message commands\n"
         "   -help:  obtain this listing\n"
         "   -nojnl:  on startup don't open a journal file (can be turned on later with SET MODE JOURNAL\n"
         "   -noverify:  on startup turn off verify mode (can be turned on later with SET MODE VERIFY\n"
         "   -verify:  on startup turn on the verify mode for all scripts in session (Cannot be changed in this session. Overrides -noverify.)\n"
         "   -script scriptname [arguments]: execute the specified script and exit: SPECIFY THIS LAST\n"
         "   -version lists the version number of Ferret and stops. \n");
  exit(0);
}

#ifdef NDEBUG
/*
 * Signal handler for SIGILL, SIGFPE, and SIGSEGV 
 * (ie, just program-crashing signals, not user-generated signals)
 * for generating a stderr message for LAS and exiting gracefully.
 * Only for production (not debug); for debug allow the crash to happen.
 */
static void fer_signal_handler(int signal_num)
{
  fprintf(stderr, "**ERROR Ferret crash; signal = %d\n", signal_num);
  fflush(stderr);
  exit(-1);
}
#endif


static int ttout_lun=TTOUT_LUN;


int main(int oargc, char *oargv[])
{
  int status;
  int argc = oargc;
  char **argv = oargv;

  int i=1;
  int j=1;
  double rmem_size = 0;
  int pplmem_size;

  int journalfile = 1;
  int verify_flag = 1;
  int verify_always = 0;
  int len_str;
  int bat_mode;

  its_script = 0;
  arg_pos = 0;

#ifdef MIXING_NAG_F90_AND_C
  f90_io_init();
#endif

#ifdef __CYGWIN__
  for_rtl_init_(&argc, argv);
#endif

#ifdef NDEBUG
  /* Catch SIGILL, SIGFPE, and SIGSEGV - if not compiled debug */
  if ( (signal(SIGILL, fer_signal_handler) == SIG_ERR) ||
       (signal(SIGFPE, fer_signal_handler) == SIG_ERR) ||
       (signal(SIGSEGV, fer_signal_handler) == SIG_ERR) ) {
     perror("**ERROR Unable to catch SIGILL, SIGFPE, or SIGSEGV");
     exit(1);
  }
#endif

  /* decode the command line options: "-memsize", and "-unmapped" */
  // pre-2017 code:   rmem_size = (double)mem_size/1.E6;
  /* 5/17     pass rmem_size as is to init_memory, convert it there*/ 
  while (i<argc) {
    if (strcmp(argv[i],"-version")==0){
      FORTRAN(version_only)();
	  exit(0);
    } else if (strcmp(argv[i],"-memsize")==0){
      if (++i==argc) help_text();
      if ( sscanf(argv[i++],"%lf",&rmem_size) != 1 ) help_text();
      if ( rmem_size <= 0.0 ) help_text();
      // pre-2017 code:    mem_size = (size_t)(rmem_size * 1.E6);
    } else if (strcmp(argv[i],"-unmapped")==0) {
      WindowMapping(0);  /* new routine added to xopws.c */
      i++;    /* advance to next argument */
    } else if (strcmp(argv[i],"-gif")==0) {
      char *meta_name = ".gif";	/* Unused dummy name */
	  bat_mode = 0;
      FORTRAN(set_batch_graphics)(meta_name, &bat_mode);  /* inhibit X output altogether */
      ++i;
    } else if (strcmp(argv[i],"-secure")==0) {
      set_secure();
      ++i;
    } else if (strcmp(argv[i],"-server")==0) {
      set_server();
      ++i;
    } else if (strcmp(argv[i],"-nojnl")==0) {
      journalfile = 0;
	  /*FORTRAN(set_start_jnl_file)(journalfile);*/ 
      ++i;
	  
    } else if (strcmp(argv[i],"-batch")==0) {
      char *meta_name = "metafile.plt";
      if (++i < argc && argv[i][0] != '-'){
	  meta_name = argv[i++];
      }
	  bat_mode = 1;
      FORTRAN(set_batch_graphics)(meta_name, &bat_mode);  /* inhibit X output altogether*/
	  
    } else if (strcmp(argv[i],"-noverify")==0) {
      verify_flag = 0;    
	  ++i;
	  
    } else if (strcmp(argv[i],"-verify")==0) {
      verify_always = 1;    
	  ++i;
      
    /* -script mode implies -server and -nojnl and noverify*/
    } else if (strcmp(argv[i],"-script")==0)  {

	  char *script_name = "noscript";
	  set_server();
	  journalfile = 0;
	  verify_flag = 0;
	
	  /*//<YWEI> this is added because sometime string arguments are not
	  //parsed correctly by the system*/
          if (++i < argc){
		script_name = argv[i];

		its_script = 1;
		len_str = strlen(script_name);

                for(j = 0; j < len_str; j++){
		     if(argv[i][j] == ' '){
		         argv[i][j] = '\0';
                         j++;
                         break;
		     }
                }

		arg_pos = 0;

                if(j < len_str){
		     while(j < len_str) {
                        script_args[arg_pos++] = argv[i][j++];
		     }

		     if (i+1 < argc) {
			   script_args[arg_pos++] = ' ';
		     }
		}

                len_str = strlen(script_name);

		FORTRAN(save_scriptfile_name)(script_name, &len_str, &its_script);

		if (its_script!=1 || strcmp(script_name,"noscript")==0) {

 			help_text();
	        }

		i++;

		while (i < argc){

			len_str = strlen(argv[i]);
			j = 0;
			while (j < len_str) {
				script_args[arg_pos++] = argv[i][j++];
			}

			if (i+1 < argc) {
			       script_args[arg_pos++] = ' ';
		        }
		        i++;
		}

		/* //</YWEI> */

                script_args[arg_pos]='\0';

	  } 

      } else  /* -help also comes here */
      help_text();
  }

  /* initial allocation of memory space */

  /* ***** COMMENTED OUT 2/2017 with removal of block-oriented memory */

  //  mem_blk_size =  mem_size / max_mem_blks;
  //  j = (int)(mem_size - ((size_t)mem_blk_size * (size_t) max_mem_blks));
  //  if ( (mem_blk_size <= 0) || (j < 0) || (j >= max_mem_blks) ) { 
  //    printf("Internal overflow expressing %#.1f Mwords as words (%lu) \n",rmem_size,(unsigned long)mem_size);
  //    printf("Unable to allocate the requested %#.1f Mwords of memory.\n",rmem_size);
  //    exit(0);
  //  }
  //  /* Reset mem_size to exactly the size Ferret thinks it is being handed */
  //  mem_size = (size_t)mem_blk_size * (size_t)max_mem_blks;
  //  *memory = (DFTYPE *) malloc(mem_size*sizeof(DFTYPE));
  //
  //  if ( *memory == NULL ) {
  //    printf("Unable to allocate the requested %#.1f Mwords of memory.\n",(double)mem_size/1.E6);
  //    exit(0);
  //  }

  /* ***** END OF COMMENTED OUT MEMORY CODE */
 
  /* initial allocation of PPLUS memory size pointer*/
  pplmem_size = (int)(0.5* 1.E6);  
  FORTRAN(save_ppl_memory_size)( &pplmem_size ); 
  ppl_memory = (float *) FerMem_Malloc(sizeof(float) * pplmem_size, __FILE__, __LINE__);

  if ( ppl_memory == NULL ) {
    printf("Unable to allocate the initial %d words of PLOT memory.\n",pplmem_size);
    exit(1);
  }
  /* initialize stuff: keyboard, todays date, grids, GFDL terms, PPL brain */
  FORTRAN(initialize_ferret)();

  /*  prepare appropriate console input state and open the output journal file */

  if ( journalfile ) {
    FORTRAN(init_journal)( &status );
  } else {
    FORTRAN(no_journal)();
  }

  if (verify_always) verify_flag = 1;

  if ( verify_flag ==0) {
    FORTRAN(turnoff_verify)( &status );
  }

  if ( verify_always ==1) {
    FORTRAN(turnon_verify_always)( &status );
  }

  /* initialize size and shape of memory and linked lists */
  FORTRAN(init_memory)(&rmem_size);

  command_line_run();
  /* 
   *kob* 5/97 - need to close f90 files and flush buffers.....
   */

#ifdef MIXING_NAG_F90_AND_C
  f90_io_finish();
#endif
#ifdef __CYGWIN__
  for_rtl_finish_(&argc, argv);
#endif
  return 0;
}

static void command_line_run()
{
  FILE *fp = 0;
  char init_command[2176], script_file[2048], *home = getenv("HOME");
  int ipath = 0;
  int script_resetmem = 0;

  /* turn on ^C interrupts  */
  /* 10/97 *kob* add check for gui now that there is only one main program */
  FORTRAN(set_ctrl_c)( FORTRAN(ctrlc_ast) );

  /* program name and revision number */
  /* 10/97 *kob* add check for gui now that there is only one main program */
  if (its_script==0) FORTRAN(proclaim_c)( &ttout_lun, "\t" );

  /* set up to execute $HOME/.ferret if it exists: '\GO "$HOME/.ferret"' */
  /* --> need to see if it exists!!! */
  /* KMS 07/2019 - if ./.ferret exists, use it instead of $HOME/.ferret */
  fp = fopen("./.ferret", "r");
  if ( fp != NULL ) {
    fclose( fp );
    strcpy( init_command, "GO \"./.ferret\"" );
  }
  else if ( home != NULL ) {
    strcpy( init_command, home );
    strcat( init_command, "/.ferret" );
    fp = fopen( init_command, "r" );
    if ( fp != NULL ) {
      fclose( fp );
      strcpy( init_command, "GO \"$HOME/.ferret\"" );
    }
    else
      strcpy( init_command, " " );
  }
  else {
    strcpy( init_command, " " );
  }

  /* If Ferret was started with the -script switch, execute the script with its args. */
  
    if (its_script)
    {
        /* assume Unix-style passing of Holerith strings - add size as int to end */
	FORTRAN(get_scriptfile_name)(script_file, &ipath, 2048);
      if ( ipath ) {
	  strcat( init_command, "; GO \"" ); 
	  strcat( init_command, script_file );
	  strcat( init_command, "\"" );
	  strcat( init_command, " ");
	  } else {
	  strcat( init_command, "; GO " ); 
	  strcat( init_command, script_file );
	  strcat( init_command, " ");
      }
	  if (arg_pos !=0) {
		   strcat( init_command, script_args );
	  }
	  strcat( init_command, "; EXIT/PROGRAM");
    }

  /* allocate the shared buffer */
  sBuffer = (sharedMem *)FerMem_Malloc(sizeof(sharedMem), __FILE__, __LINE__);

 
  /* run the initialization file
     * Note 1: do not pass a fixed string as the command - FERRET needs to blank it
     * Note 2: if not under GUI control we will not normally exit FERRET_DISPATCH
     *	  until we are ready to exit FERRET 
     * Note 3: in -script mode, a SET MEM command executes commands in this
	      routine to reset memory.  Once this has been done, call ferret_dispatch_c
		  with blank second argument to continue executing commands in the script.
		  Reset the flag script_resetmem so that further SET MEM commands are executed
		  as well.*/
  while ( 1) {
    /*    ferret_dispatch_( memory, init_command, rtn_buff );  FORTRAN version */

	if ( script_resetmem == 0 )
	  {
      ferret_dispatch_c( init_command, sBuffer );
	  } else {
	  ferret_dispatch_c( " ", sBuffer );
	  script_resetmem = 0;
	  }

    /* debugging flow control checks */
    /*
      printf("       --> control returned to C MAIN:%d %d %d\n",
      sBuffer->flags[FRTN_CONTROL],
      sBuffer->flags[FRTN_STATUS],
      sBuffer->flags[FRTN_ACTION]);
    */

    /* ***** REALLOCATE MEMORY ***** */
    if (sBuffer->flags[FRTN_ACTION] == FACTN_MEM_RECONFIGURE) {

      /* TAKE NO ACTION -- MEMORY NO LONGER ALLOCATED HERE */

/* **** START OF PRE-2017 MEMORY MANAGEMENT CODE */
//      old_mem_blk_size = mem_blk_size;
//      mem_blk_size = sBuffer->flags[FRTN_IDATA1];
//      mem_size = (size_t)mem_blk_size * (size_t)max_mem_blks;
//      /* Make sure this has not overflowed */
//      blk_size = mem_size / (size_t) max_mem_blks;
//      if ( blk_size != (size_t)mem_blk_size ) {
//        rmem_size = (double)mem_blk_size * (double)max_mem_blks / 1.0E6;
//        printf("Internal overflow expressing %#.1f Mwords as words (%lu) \n",rmem_size,(unsigned long)mem_size);
//        printf("Unable to allocate the requested %#.1f Mwords of memory.\n",rmem_size);
//	mem_blk_size = old_mem_blk_size;
//	mem_size = (size_t)mem_blk_size * (size_t)max_mem_blks;
//	printf("Memory remaining at %#.1f Mwords.\n", (double)mem_size/1.E6);
//      }
//      else {
//        /*
//	  printf("memory reconfiguration requested: %lu\n",(unsigned long)mem_size);
//	  printf("new mem_blk_size = %d\n",mem_blk_size);
//        */
//        free( (void *) *memory );
//        *memory = (DFTYPE *) malloc(mem_size*sizeof(DFTYPE));
//
//        if ( *memory == NULL ) {
//          printf("Unable to allocate %#.1f Mwords of memory.\n", (double)mem_size/1.E6);
//          mem_blk_size = old_mem_blk_size;
//          mem_size = (size_t)mem_blk_size * (size_t)max_mem_blks;
//          *memory = (DFTYPE *) malloc(mem_size*sizeof(DFTYPE));
//
//          if ( *memory == NULL ) {
//            printf("Unable to reallocate previous memory of %#.1f Mwords.\n",(double)(mem_size)/1.E6);
//            exit(0);
//          }
//	  printf("Restoring previous memory of %#.1f Mwords.\n", (double)(mem_size)/1.E6);
//        }
//      }
//      FORTRAN(init_memory)();
//      script_resetmem = 1;
/* **** END OF PRE-2017 MEMORY MANAGEMENT CODE */

    }

    /* ***** EXIT ***** */
    else if  (sBuffer->flags[FRTN_ACTION] == FACTN_EXIT ) {
      /*      printf("exit from FERRET requested\n"); */
      FORTRAN(finalize_ferret)();
      if ( sBuffer != NULL )
          FerMem_Free(sBuffer, __FILE__, __LINE__);
      if ( ppl_memory != NULL )
          FerMem_Free(ppl_memory, __FILE__, __LINE__);
#ifdef MEMORYDEBUG
      (void) ReportAnyMemoryLeaks();
#endif
      exit(0);
    }

    /* ***** TEMPORARY RETURN IN CASE MAIN NEEDS TO DISPLAY FERRET MSG ***** */
    else if ( sBuffer->flags[FRTN_ACTION] != FACTN_NO_ACTION ) {

      /*
	check the sBuffer->flags[FRTN_STATUS] to see if you need
	to display any messages from FERRET to the user
      */
      if (sBuffer->flags[FRTN_STATUS] != 3 ) {
	printf("error buffer from FERRET: %d\n", sBuffer->numStrings);
	printf("error lines:\n%s\n",sBuffer->text);
      }
      else
	printf("no action - returning from GUI to FERRET\n");

    }
  }
}
