//*----------------------------------------------------------------*
//* JOB:     NIGHTLY                                               *
//* PURPOSE: Nightly account processing batch                      *
//* SCHEDULE: Every night at 23:00                                 *
//*----------------------------------------------------------------*
//NIGHTLY  JOB (ACCT-9001),'NIGHTLY BATCH',
//             CLASS=A,MSGCLASS=X,
//             NOTIFY=&SYSUID,
//             MSGLEVEL=(1,1)
//*
//* STEP010 - Calculate balances for all active accounts
//*
//STEP010  EXEC PGM=ACCTBAL,REGION=256M
//STEPLIB  DD DSN=PROD.LOADLIB,DISP=SHR
//CUSTFILE DD DSN=PROD.CUSTOMER.MASTER,DISP=SHR
//TRANFILE DD DSN=PROD.DAILY.TRANSACTIONS,DISP=SHR
//REPFILE  DD DSN=WORK.NIGHTLY.REPORT,
//            DISP=(NEW,CATLG,DELETE),
//            SPACE=(CYL,(10,5)),
//            DCB=(RECFM=FB,LRECL=133,BLKSIZE=13300)
//SYSOUT   DD SYSOUT=*
//*
//* STEP020 - Process payments (only if STEP010 RC=0)
//*
//STEP020  EXEC PGM=PYMT001,REGION=256M,
//             COND=(0,NE,STEP010)
//STEPLIB  DD DSN=PROD.LOADLIB,DISP=SHR
//PYMTFILE DD DSN=PROD.DAILY.PAYMENTS,DISP=SHR
//REJECTFILE DD DSN=WORK.NIGHTLY.REJECTS,
//              DISP=(NEW,CATLG,DELETE),
//              SPACE=(CYL,(5,2)),
//              DCB=(RECFM=FB,LRECL=200,BLKSIZE=20000)
//SYSOUT   DD SYSOUT=*
//*
//* STEP030 - Print monthly statements (only if STEP020 RC<=4)
//*
//STEP030  EXEC PGM=STMTPRT,REGION=128M,
//             COND=(4,LT,STEP020)
//STEPLIB  DD DSN=PROD.LOADLIB,DISP=SHR
//ACCTFILE DD DSN=PROD.CUSTOMER.MASTER,DISP=SHR
//STMTFILE DD DSN=PROD.STATEMENTS.DAILY,
//            DISP=(NEW,CATLG,DELETE),
//            SPACE=(CYL,(20,10)),
//            DCB=(RECFM=FB,LRECL=133,BLKSIZE=13300)
//SYSOUT   DD SYSOUT=*
