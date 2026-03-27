      *----------------------------------------------------------------*
      * PROGRAM:  STMTPRT                                             *
      * PURPOSE:  Monthly Statement Print and PDF Generation          *
      * AUTHOR:   TABFORGE-AI                                         *
      * CALLS:    ERRHANDR, FMTDATE, FMTAMT                           *
      * COPYBOOKS: CUSTMAST, ERRDATA                                  *
      *----------------------------------------------------------------*
       IDENTIFICATION DIVISION.
       PROGRAM-ID.     STMTPRT.
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
           SELECT STMTFILE  ASSIGN TO UT-S-STMTFILE
                            ORGANIZATION IS SEQUENTIAL
                            ACCESS MODE  IS SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD  ACCTFILE
           RECORDING MODE IS F
           BLOCK CONTAINS 0 RECORDS
           RECORD CONTAINS 200 CHARACTERS.
       01  ACCTFILE-REC               PIC X(200).

       FD  STMTFILE
           RECORDING MODE IS F
           RECORD CONTAINS 133 CHARACTERS.
       01  STMTFILE-REC               PIC X(133).

       WORKING-STORAGE SECTION.
           05  WS-PROGRAM-NAME        PIC X(8)  VALUE 'STMTPRT'.
           05  WS-EOF-ACCTFILE        PIC X(1)  VALUE 'N'.
               88  EOF-ACCTFILE           VALUE 'Y'.
           05  WS-STMT-COUNT          PIC 9(7)  COMP VALUE ZERO.
           05  WS-PAGE-NUMBER         PIC 9(5)  COMP VALUE ZERO.
           05  WS-LINE-COUNT          PIC 9(3)  COMP VALUE ZERO.
           05  WS-MAX-LINES           PIC 9(3)  VALUE 60.
           05  WS-FORMATTED-DATE      PIC X(20).
           05  WS-FORMATTED-AMOUNT    PIC X(20).
           05  WS-PRINT-LINE          PIC X(133).

       COPY CUSTMAST.
       COPY ERRDATA.

       PROCEDURE DIVISION.

       1000-INIT.
           MOVE ZERO TO WS-STMT-COUNT
           MOVE ZERO TO WS-PAGE-NUMBER
           MOVE ZERO TO WS-LINE-COUNT
           OPEN INPUT  ACCTFILE
           OPEN OUTPUT STMTFILE
           PERFORM 2000-READ-ACCOUNT UNTIL EOF-ACCTFILE
           PERFORM 9000-END.

       2000-READ-ACCOUNT.
           READ ACCTFILE INTO CUSTOMER-RECORD
               AT END MOVE 'Y' TO WS-EOF-ACCTFILE
           END-READ
           IF NOT EOF-ACCTFILE
               PERFORM 3000-PRINT-HEADER
               PERFORM 3100-PRINT-BODY
               PERFORM 3200-PRINT-FOOTER
               ADD 1 TO WS-STMT-COUNT
           END-IF.

       3000-PRINT-HEADER.
           ADD 1 TO WS-PAGE-NUMBER
           MOVE ZERO TO WS-LINE-COUNT
           CALL 'FMTDATE' USING LAST-UPDATE-DATE
                                WS-FORMATTED-DATE
                                WS-RETURN-CODE
           MOVE SPACES TO WS-PRINT-LINE
           STRING 'ACCOUNT STATEMENT - PAGE: ' DELIMITED SIZE
                  WS-PAGE-NUMBER               DELIMITED SIZE
                  ' DATE: '                    DELIMITED SIZE
                  WS-FORMATTED-DATE            DELIMITED SIZE
                  INTO WS-PRINT-LINE
           WRITE STMTFILE-REC FROM WS-PRINT-LINE.

       3100-PRINT-BODY.
           CALL 'FMTAMT' USING CUSTOMER-BALANCE
                               WS-FORMATTED-AMOUNT
                               CURRENCY-CODE
                               WS-RETURN-CODE
           MOVE SPACES TO WS-PRINT-LINE
           STRING 'CUSTOMER: ' DELIMITED SIZE
                  CUSTOMER-NAME DELIMITED SIZE
                  ' ID: '       DELIMITED SIZE
                  CUSTOMER-ID   DELIMITED SIZE
                  INTO WS-PRINT-LINE
           WRITE STMTFILE-REC FROM WS-PRINT-LINE
           MOVE SPACES TO WS-PRINT-LINE
           STRING 'BALANCE:  ' DELIMITED SIZE
                  WS-FORMATTED-AMOUNT DELIMITED SIZE
                  INTO WS-PRINT-LINE
           WRITE STMTFILE-REC FROM WS-PRINT-LINE
           ADD 2 TO WS-LINE-COUNT
           IF WS-LINE-COUNT >= WS-MAX-LINES
               PERFORM 3000-PRINT-HEADER
           END-IF.

       3200-PRINT-FOOTER.
           MOVE SPACES TO WS-PRINT-LINE
           MOVE '*** END OF STATEMENT ***' TO WS-PRINT-LINE
           WRITE STMTFILE-REC FROM WS-PRINT-LINE.

       9000-END.
           CLOSE ACCTFILE
                 STMTFILE
           IF WS-STMT-COUNT = ZERO
               MOVE 'STMTPRT'   TO ERR-PROGRAM-NAME
               MOVE '9000-END'  TO ERR-PARAGRAPH
               MOVE 0010        TO ERR-CODE
               MOVE 'NO ACCOUNTS PROCESSED' TO ERR-MESSAGE
               CALL 'ERRHANDR' USING ERROR-RECORD
               MOVE RC-WARNING  TO WS-RETURN-CODE
           ELSE
               MOVE RC-SUCCESS  TO WS-RETURN-CODE
           END-IF
           STOP RUN.
