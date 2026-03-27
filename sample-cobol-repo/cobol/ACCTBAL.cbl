      *----------------------------------------------------------------*
      * PROGRAM:  ACCTBAL                                             *
      * PURPOSE:  Account Balance Calculation and Inquiry             *
      * AUTHOR:   TABFORGE-AI                                         *
      * CALLS:    DBREAD01, VALCUST, ERRHANDR                         *
      * COPYBOOKS: CUSTMAST, ACCTDATA, ERRDATA                        *
      *----------------------------------------------------------------*
       IDENTIFICATION DIVISION.
       PROGRAM-ID.     ACCTBAL.
       AUTHOR.         TABFORGE-AI.
       DATE-WRITTEN.   2025-01-15.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-ZOS.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT CUSTFILE  ASSIGN TO UT-S-CUSTFILE
                            ORGANIZATION IS SEQUENTIAL
                            ACCESS MODE  IS SEQUENTIAL.
           SELECT TRANFILE  ASSIGN TO UT-S-TRANFILE
                            ORGANIZATION IS SEQUENTIAL
                            ACCESS MODE  IS SEQUENTIAL.
           SELECT REPFILE   ASSIGN TO UT-S-REPFILE
                            ORGANIZATION IS SEQUENTIAL
                            ACCESS MODE  IS SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD  CUSTFILE
           RECORDING MODE IS F
           BLOCK CONTAINS 0 RECORDS
           RECORD CONTAINS 200 CHARACTERS.
       01  CUSTFILE-REC               PIC X(200).

       FD  TRANFILE
           RECORDING MODE IS F
           BLOCK CONTAINS 0 RECORDS
           RECORD CONTAINS 150 CHARACTERS.
       01  TRANFILE-REC               PIC X(150).

       FD  REPFILE
           RECORDING MODE IS F
           RECORD CONTAINS 133 CHARACTERS.
       01  REPFILE-REC                PIC X(133).

       WORKING-STORAGE SECTION.
           05  WS-PROGRAM-NAME        PIC X(8)  VALUE 'ACCTBAL'.
           05  WS-VERSION             PIC X(4)  VALUE '1.00'.
           05  WS-EOF-CUSTFILE        PIC X(1)  VALUE 'N'.
               88  EOF-CUSTFILE           VALUE 'Y'.
           05  WS-EOF-TRANFILE        PIC X(1)  VALUE 'N'.
               88  EOF-TRANFILE           VALUE 'Y'.
           05  WS-PROCESS-COUNT       PIC 9(7)  COMP VALUE ZERO.
           05  WS-ERROR-COUNT         PIC 9(5)  COMP VALUE ZERO.
           05  WS-CALC-BALANCE        PIC S9(13)V99 COMP-3.
           05  WS-PREV-BALANCE        PIC S9(13)V99 COMP-3.

       COPY CUSTMAST.
       COPY ACCTDATA.
       COPY ERRDATA.

       PROCEDURE DIVISION.

       1000-INIT.
           MOVE 'ACCTBAL'   TO WS-PROGRAM-NAME
           MOVE ZERO        TO WS-PROCESS-COUNT
           MOVE ZERO        TO WS-ERROR-COUNT
           OPEN INPUT  CUSTFILE
                       TRANFILE
           OPEN OUTPUT REPFILE
           CALL 'VALCUST' USING CUSTOMER-RECORD
                                WS-RETURN-CODE
           IF WS-RETURN-CODE > RC-WARNING
               MOVE 'ACCTBAL'  TO ERR-PROGRAM-NAME
               MOVE '1000-INIT' TO ERR-PARAGRAPH
               CALL 'ERRHANDR' USING ERROR-RECORD
               STOP RUN
           END-IF
           PERFORM 2000-PROCESS UNTIL EOF-CUSTFILE
           PERFORM 9000-END.

       2000-PROCESS.
           READ CUSTFILE INTO CUSTOMER-RECORD
               AT END MOVE 'Y' TO WS-EOF-CUSTFILE
           END-READ
           IF NOT EOF-CUSTFILE
               PERFORM 2100-READ-TRANSACTIONS
               PERFORM 3000-CALC-BALANCE
               ADD 1 TO WS-PROCESS-COUNT
           END-IF.

       2100-READ-TRANSACTIONS.
           MOVE ZERO TO TX-TOTAL-COUNT
           MOVE ZERO TO TX-TOTAL-AMOUNT
           READ TRANFILE INTO ACCOUNT-RECORD
               AT END MOVE 'Y' TO WS-EOF-TRANFILE
           END-READ
           PERFORM UNTIL EOF-TRANFILE
               ADD 1            TO TX-TOTAL-COUNT
               ADD PENDING-AMOUNT TO TX-TOTAL-AMOUNT
               READ TRANFILE INTO ACCOUNT-RECORD
                   AT END MOVE 'Y' TO WS-EOF-TRANFILE
               END-READ
           END-PERFORM
           CALL 'DBREAD01' USING ACCOUNT-NUMBER
                                 ACCOUNT-RECORD
                                 WS-RETURN-CODE.

       3000-CALC-BALANCE.
           MOVE CUSTOMER-BALANCE TO WS-PREV-BALANCE
           COMPUTE WS-CALC-BALANCE =
               AVAILABLE-BALANCE + TX-TOTAL-AMOUNT
           IF WS-CALC-BALANCE < ZERO
               MOVE SEV-WARNING    TO ERR-SEVERITY
               MOVE 'ACCTBAL'      TO ERR-PROGRAM-NAME
               MOVE '3000-CALC-BALANCE' TO ERR-PARAGRAPH
               MOVE 0042           TO ERR-CODE
               MOVE 'NEGATIVE BALANCE DETECTED' TO ERR-MESSAGE
               CALL 'ERRHANDR' USING ERROR-RECORD
               ADD 1 TO WS-ERROR-COUNT
           END-IF
           MOVE WS-CALC-BALANCE TO CUSTOMER-BALANCE
           WRITE REPFILE-REC FROM CUSTOMER-RECORD.

       9000-END.
           CLOSE CUSTFILE
                 TRANFILE
                 REPFILE
           IF WS-ERROR-COUNT > ZERO
               MOVE RC-WARNING TO WS-RETURN-CODE
           ELSE
               MOVE RC-SUCCESS TO WS-RETURN-CODE
           END-IF
           STOP RUN.
