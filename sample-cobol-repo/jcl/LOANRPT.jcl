//LOANRPT  JOB (ACCT002),'LOAN PROCESSING REPORT',
//             CLASS=A,MSGCLASS=X,NOTIFY=&SYSUID
//*-------------------------------------------------------------------*
//* LOANRPT - Daily Loan Processing and Audit Report                  *
//* Schedule: Daily at 23:00                                          *
//*-------------------------------------------------------------------*
//STEP010  EXEC PGM=LOANPROC
//STEPLIB  DD DSN=SYS1.LOADLIB,DISP=SHR
//CUSTFILE DD DSN=PROD.CUSTOMER.MASTER,DISP=SHR
//LOANFILE DD DSN=PROD.LOAN.MASTER,DISP=SHR
//OUTFILE  DD DSN=WORK.LOANPROC.OUTPUT,
//            DISP=(NEW,PASS),
//            SPACE=(CYL,(10,5)),
//            DCB=(RECFM=FB,LRECL=300,BLKSIZE=30000)
//AUDITFIL DD DSN=PROD.LOAN.AUDIT.G0000V00,
//            DISP=(NEW,CATLG),
//            SPACE=(CYL,(5,2)),
//            DCB=(RECFM=FB,LRECL=200,BLKSIZE=20000)
//SYSOUT   DD SYSOUT=*
//*
//STEP020  EXEC PGM=RPRT001,COND=(8,LT,STEP010)
//STEPLIB  DD DSN=SYS1.LOADLIB,DISP=SHR
//INFILE   DD DSN=WORK.LOANPROC.OUTPUT,DISP=(OLD,DELETE)
//RPTFILE  DD DSN=PROD.LOAN.REPORT.G0000V00,
//            DISP=(NEW,CATLG),
//            SPACE=(CYL,(15,5)),
//            DCB=(RECFM=FB,LRECL=133,BLKSIZE=13300)
//SYSOUT   DD SYSOUT=*
