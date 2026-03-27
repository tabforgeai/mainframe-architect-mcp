//INTRUN   JOB (ACCT001),'MONTHLY INTEREST RUN',
//             CLASS=A,MSGCLASS=X,NOTIFY=&SYSUID
//*-------------------------------------------------------------------*
//* INTRUN - Monthly Interest Calculation and Report                  *
//* Schedule: Last business day of each month                         *
//*-------------------------------------------------------------------*
//STEP010  EXEC PGM=INTCALC
//STEPLIB  DD DSN=SYS1.LOADLIB,DISP=SHR
//ACCTFILE DD DSN=PROD.ACCOUNT.MASTER,DISP=SHR
//LOANFILE DD DSN=PROD.LOAN.MASTER,DISP=SHR
//INTFILE  DD DSN=WORK.INTCALC.OUTPUT,
//            DISP=(NEW,PASS),
//            SPACE=(CYL,(5,2)),
//            DCB=(RECFM=FB,LRECL=200,BLKSIZE=20000)
//SYSOUT   DD SYSOUT=*
//*
//STEP020  EXEC PGM=RPRT001,COND=(8,LT,STEP010)
//STEPLIB  DD DSN=SYS1.LOADLIB,DISP=SHR
//INFILE   DD DSN=WORK.INTCALC.OUTPUT,DISP=(OLD,DELETE)
//RPTFILE  DD DSN=PROD.INTEREST.REPORT.G0000V00,
//            DISP=(NEW,CATLG),
//            SPACE=(CYL,(10,5)),
//            DCB=(RECFM=FB,LRECL=133,BLKSIZE=13300)
//SYSOUT   DD SYSOUT=*
