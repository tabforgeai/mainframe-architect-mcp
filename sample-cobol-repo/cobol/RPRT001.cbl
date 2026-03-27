      *----------------------------------------------------------------*
      * PROGRAM:  RPRT001                                             *
      * PURPOSE:  Batch Report Generator — consolidates account data  *
      * AUTHOR:   TABFORGE-AI                                         *
      * CALLS:    STMTPRT, FMTDATE, FMTAMT                           *
      * COPYBOOKS: CUSTMAST, ACCTDATA, TRANDATA                       *
      *----------------------------------------------------------------*
       IDENTIFICATION DIVISION.
       PROGRAM-ID.     RPRT001.
       AUTHOR.         TABFORGE-AI.
       DATE-WRITTEN.   2025-02-01.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-ZOS.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT INFILE   ASSIGN TO UT-S-INFILE
                           ORGANIZATION IS SEQUENTIAL
                           ACCESS MODE  IS SEQUENTIAL.
           SELECT RPTFILE  ASSIGN TO UT-S-RPTFILE
                           ORGANIZATION IS SEQUENTIAL
                           ACCESS MODE  IS SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD  INFILE
           RECORDING MODE IS F
           RECORD CONTAINS 400 CHARACTERS.
       01  INFILE-REC                 PIC X(400).

       FD  RPTFILE
           RECORDING MODE IS F
           RECORD CONTAINS 133 CHARACTERS.
       01  RPTFILE-REC                PIC X(133).

       WORKING-STORAGE SECTION.
           05  WS-PROGRAM-NAME        PIC X(8)  VALUE 'RPRT001'.
           05  WS-EOF-INFILE          PIC X(01) VALUE 'N'.
               88  EOF-INFILE             VALUE 'Y'.
           05  WS-REPORT-DATE         PIC X(10) VALUE SPACES.
           05  WS-PAGE-NUM            PIC 9(04) COMP VALUE ZERO.
           05  WS-LINE-COUNT          PIC 9(04) COMP VALUE ZERO.
           05  WS-RECORD-COUNT        PIC 9(07) COMP VALUE ZERO.
           05  WS-TOTAL-AMOUNT        PIC S9(13)V99 COMP-3 VALUE ZERO.
           05  WS-LINES-PER-PAGE      PIC 9(03) COMP VALUE 60.
           05  WS-PROCESS-RC          PIC S9(04) COMP VALUE ZERO.
           05  WS-FORMATTED-DATE      PIC X(10) VALUE SPACES.
           05  WS-FORMATTED-AMT       PIC X(18) VALUE SPACES.

       COPY CUSTMAST.
       COPY ACCTDATA.
       COPY TRANDATA.

       PROCEDURE DIVISION.

       1000-INIT.
           MOVE 'RPRT001' TO WS-PROGRAM-NAME
           MOVE ZERO TO WS-PAGE-NUM
           MOVE ZERO TO WS-RECORD-COUNT
           MOVE ZERO TO WS-TOTAL-AMOUNT
           CALL 'FMTDATE' USING TRANS-PERIOD-FROM
                                WS-FORMATTED-DATE
           MOVE WS-FORMATTED-DATE TO WS-REPORT-DATE
           OPEN INPUT  INFILE
           OPEN OUTPUT RPTFILE
           PERFORM 2000-PROCESS-REPORT UNTIL EOF-INFILE
           PERFORM 2300-FORMAT-TOTAL
           PERFORM 9000-END.

       2000-PROCESS-REPORT.
           READ INFILE INTO CUSTOMER-RECORD
               AT END MOVE 'Y' TO WS-EOF-INFILE
           END-READ
           IF NOT EOF-INFILE
               IF WS-LINE-COUNT >= WS-LINES-PER-PAGE
                   PERFORM 2100-FORMAT-HEADER
               END-IF
               PERFORM 2200-FORMAT-DETAIL
               ADD 1 TO WS-RECORD-COUNT
           END-IF.

       2100-FORMAT-HEADER.
           ADD 1 TO WS-PAGE-NUM
           MOVE ZERO TO WS-LINE-COUNT
           CALL 'STMTPRT' USING CUSTOMER-RECORD
                                WS-PROCESS-RC.

       2200-FORMAT-DETAIL.
           CALL 'FMTAMT' USING AVAILABLE-BALANCE
                               WS-FORMATTED-AMT
           ADD AVAILABLE-BALANCE TO WS-TOTAL-AMOUNT
           WRITE RPTFILE-REC FROM CUSTOMER-RECORD
           ADD 1 TO WS-LINE-COUNT.

       2300-FORMAT-TOTAL.
           CALL 'FMTAMT' USING WS-TOTAL-AMOUNT
                               WS-FORMATTED-AMT
           WRITE RPTFILE-REC FROM CUSTOMER-RECORD.

       9000-END.
           CLOSE INFILE
                 RPTFILE
           STOP RUN.
