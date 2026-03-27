//*----------------------------------------------------------------*
//* JOB:     MONTHEND                                              *
//* PURPOSE: Month-end closing and statement generation            *
//* SCHEDULE: Last business day of every month                     *
//*----------------------------------------------------------------*
//MONTHEND JOB (ACCT-9002),'MONTH END CLOSE',
//             CLASS=B,MSGCLASS=X,
//             NOTIFY=&SYSUID,
//             MSGLEVEL=(1,1)
//*
//* STEP010 - Final balance recalculation for month-end
//*
//STEP010  EXEC PGM=ACCTBAL,REGION=512M
//STEPLIB  DD DSN=PROD.LOADLIB,DISP=SHR
//CUSTFILE DD DSN=PROD.CUSTOMER.MASTER,DISP=SHR
//TRANFILE DD DSN=PROD.MONTHLY.TRANSACTIONS,DISP=SHR
//REPFILE  DD DSN=ARCH.MONTHEND.REPORT.&YYMMDD,
//            DISP=(NEW,CATLG),
//            SPACE=(CYL,(50,10)),
//            DCB=(RECFM=FB,LRECL=133,BLKSIZE=13300)
//SYSOUT   DD SYSOUT=*
//*
//* STEP020 - Generate month-end account statements
//*
//STEP020  EXEC PGM=STMTPRT,REGION=512M,
//             COND=(0,NE,STEP010)
//STEPLIB  DD DSN=PROD.LOADLIB,DISP=SHR
//ACCTFILE DD DSN=PROD.CUSTOMER.MASTER,DISP=SHR
//STMTFILE DD DSN=PROD.STATEMENTS.MONTHLY.&YYMMDD,
//            DISP=(NEW,CATLG),
//            SPACE=(CYL,(100,20)),
//            DCB=(RECFM=FB,LRECL=133,BLKSIZE=13300)
//SYSOUT   DD SYSOUT=*
//*
//* STEP030 - Process any outstanding payments
//*
//STEP030  EXEC PGM=PYMT001,REGION=256M,
//             COND=(4,LT,STEP020)
//STEPLIB  DD DSN=PROD.LOADLIB,DISP=SHR
//PYMTFILE DD DSN=PROD.MONTHEND.PAYMENTS,DISP=SHR
//REJECTFILE DD DSN=ARCH.MONTHEND.REJECTS.&YYMMDD,
//              DISP=(NEW,CATLG),
//              SPACE=(CYL,(5,2)),
//              DCB=(RECFM=FB,LRECL=200,BLKSIZE=20000)
//SYSOUT   DD SYSOUT=*
