      *----------------------------------------------------------------*
      * PROGRAM:  INTCALC                                             *
      * PURPOSE:  Monthly Interest Calculation for all accounts       *
      * AUTHOR:   TABFORGE-AI                                         *
      * CALLS:    ACCTBAL, DBUPD01, ERRHANDR                          *
      * COPYBOOKS: CUSTMAST, ACCTDATA, LOANDATA                       *
      *----------------------------------------------------------------*
       IDENTIFICATION DIVISION.
       PROGRAM-ID.     INTCALC.
       AUTHOR.         TABFORGE-AI.
       DATE-WRITTEN.   2025-02-01.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-ZOS.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT ACCTFILE  ASSIGN TO UT-S-ACCTFILE
                            ORGANIZATION IS SEQUENTIAL
                            ACCESS MODE  IS SEQUENTIAL.
           SELECT LOANFILE  ASSIGN TO UT-S-LOANFILE
                            ORGANIZATION IS SEQUENTIAL
                            ACCESS MODE  IS SEQUENTIAL.
           SELECT INTFILE   ASSIGN TO UT-S-INTFILE
                            ORGANIZATION IS SEQUENTIAL
                            ACCESS MODE  IS SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD  ACCTFILE
           RECORDING MODE IS F
           RECORD CONTAINS 400 CHARACTERS.
       01  ACCTFILE-REC               PIC X(400).

       FD  LOANFILE
           RECORDING MODE IS F
           RECORD CONTAINS 300 CHARACTERS.
       01  LOANFILE-REC               PIC X(300).

       FD  INTFILE
           RECORDING MODE IS F
           RECORD CONTAINS 200 CHARACTERS.
       01  INTFILE-REC                PIC X(200).

       WORKING-STORAGE SECTION.
           05  WS-PROGRAM-NAME        PIC X(8)  VALUE 'INTCALC'.
           05  WS-EOF-ACCTFILE        PIC X(01) VALUE 'N'.
               88  EOF-ACCTFILE           VALUE 'Y'.
           05  WS-EOF-LOANFILE        PIC X(01) VALUE 'N'.
               88  EOF-LOANFILE           VALUE 'Y'.
           05  WS-INTEREST-RATE       PIC S9(03)V9(4) COMP-3 VALUE ZERO.
           05  WS-INTEREST-AMT        PIC S9(11)V99 COMP-3 VALUE ZERO.
           05  WS-BASE-BALANCE        PIC S9(13)V99 COMP-3 VALUE ZERO.
           05  WS-NEW-BALANCE         PIC S9(13)V99 COMP-3 VALUE ZERO.
           05  WS-ACCT-COUNT          PIC 9(07) COMP VALUE ZERO.
           05  WS-TOTAL-INTEREST      PIC S9(13)V99 COMP-3 VALUE ZERO.
           05  WS-PROCESS-RC          PIC S9(04) COMP VALUE ZERO.
           05  WS-DAYS-IN-PERIOD      PIC 9(03) COMP VALUE 30.

       COPY CUSTMAST.
       COPY ACCTDATA.
       COPY LOANDATA.

       PROCEDURE DIVISION.

       1000-INIT.
           MOVE 'INTCALC' TO WS-PROGRAM-NAME
           MOVE ZERO TO WS-ACCT-COUNT
           MOVE ZERO TO WS-TOTAL-INTEREST
           OPEN INPUT  ACCTFILE
                       LOANFILE
           OPEN OUTPUT INTFILE
           PERFORM 2000-PROCESS-ACCOUNTS UNTIL EOF-ACCTFILE
           PERFORM 3000-GENERATE-REPORT
           PERFORM 9000-END.

       2000-PROCESS-ACCOUNTS.
           PERFORM 2100-READ-ACCOUNT
           IF NOT EOF-ACCTFILE
               PERFORM 2200-CALC-INTEREST
               PERFORM 2300-UPDATE-BALANCE
               ADD 1 TO WS-ACCT-COUNT
           END-IF.

       2100-READ-ACCOUNT.
           READ ACCTFILE INTO CUSTOMER-RECORD
               AT END MOVE 'Y' TO WS-EOF-ACCTFILE
           END-READ
           IF NOT EOF-ACCTFILE
               CALL 'ACCTBAL' USING CUSTOMER-ID
                                    ACCOUNT-RECORD
                                    WS-PROCESS-RC
               IF WS-PROCESS-RC > 4
                   MOVE 'INTCALC' TO ERR-PROGRAM-NAME
                   MOVE '2100-READ-ACCOUNT' TO ERR-PARAGRAPH
                   CALL 'ERRHANDR' USING ERROR-RECORD
               END-IF
           END-IF.

       2200-CALC-INTEREST.
           MOVE AVAILABLE-BALANCE TO WS-BASE-BALANCE
           MOVE LOAN-INTEREST-RATE TO WS-INTEREST-RATE
           COMPUTE WS-INTEREST-AMT =
               WS-BASE-BALANCE * WS-INTEREST-RATE
               / 365 * WS-DAYS-IN-PERIOD
           ADD WS-INTEREST-AMT TO WS-TOTAL-INTEREST.

       2300-UPDATE-BALANCE.
           COMPUTE WS-NEW-BALANCE =
               AVAILABLE-BALANCE + WS-INTEREST-AMT
           MOVE WS-NEW-BALANCE TO AVAILABLE-BALANCE
           CALL 'DBUPD01' USING CUSTOMER-ID
                                ACCOUNT-RECORD
                                WS-PROCESS-RC
           IF WS-PROCESS-RC NOT = ZERO
               MOVE 'INTCALC' TO ERR-PROGRAM-NAME
               MOVE '2300-UPDATE-BALANCE' TO ERR-PARAGRAPH
               CALL 'ERRHANDR' USING ERROR-RECORD
           END-IF.

       3000-GENERATE-REPORT.
           WRITE INTFILE-REC FROM ACCOUNT-RECORD.

       9000-END.
           CLOSE ACCTFILE
                 LOANFILE
                 INTFILE
           STOP RUN.
