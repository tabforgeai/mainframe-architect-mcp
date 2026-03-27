      *----------------------------------------------------------------*
      * PROGRAM:  PYMT001                                             *
      * PURPOSE:  Payment Processing - Debit/Credit Account           *
      * AUTHOR:   TABFORGE-AI                                         *
      * CALLS:    ACCTBAL, DBUPD01, ERRHANDR                          *
      * COPYBOOKS: CUSTMAST, ACCTDATA, ERRDATA                        *
      *----------------------------------------------------------------*
       IDENTIFICATION DIVISION.
       PROGRAM-ID.     PYMT001.
       AUTHOR.         TABFORGE-AI.
       DATE-WRITTEN.   2025-01-20.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-ZOS.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT PYMTFILE  ASSIGN TO UT-S-PYMTFILE
                            ORGANIZATION IS SEQUENTIAL
                            ACCESS MODE  IS SEQUENTIAL.
           SELECT REJECTFILE ASSIGN TO UT-S-REJECTFILE
                             ORGANIZATION IS SEQUENTIAL
                             ACCESS MODE  IS SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD  PYMTFILE
           RECORDING MODE IS F
           BLOCK CONTAINS 0 RECORDS
           RECORD CONTAINS 200 CHARACTERS.
       01  PYMTFILE-REC               PIC X(200).

       FD  REJECTFILE
           RECORDING MODE IS F
           RECORD CONTAINS 200 CHARACTERS.
       01  REJECTFILE-REC             PIC X(200).

       WORKING-STORAGE SECTION.
           05  WS-PROGRAM-NAME        PIC X(8)  VALUE 'PYMT001'.
           05  WS-EOF-PYMTFILE        PIC X(1)  VALUE 'N'.
               88  EOF-PYMTFILE           VALUE 'Y'.
           05  WS-PYMT-COUNT          PIC 9(7)  COMP VALUE ZERO.
           05  WS-REJECT-COUNT        PIC 9(5)  COMP VALUE ZERO.
           05  WS-PYMT-AMOUNT         PIC S9(13)V99 COMP-3.
           05  WS-NEW-BALANCE         PIC S9(13)V99 COMP-3.
           05  WS-SUFFICIENT-FUNDS    PIC X(1)  VALUE 'N'.
               88  FUNDS-OK               VALUE 'Y'.

       COPY CUSTMAST.
       COPY ACCTDATA.
       COPY ERRDATA.

       PROCEDURE DIVISION.

       1000-INIT.
           MOVE ZERO TO WS-PYMT-COUNT
           MOVE ZERO TO WS-REJECT-COUNT
           OPEN INPUT  PYMTFILE
           OPEN OUTPUT REJECTFILE
           PERFORM 2000-READ-PAYMENT UNTIL EOF-PYMTFILE
           PERFORM 9000-END.

       2000-READ-PAYMENT.
           READ PYMTFILE INTO ACCOUNT-RECORD
               AT END MOVE 'Y' TO WS-EOF-PYMTFILE
           END-READ
           IF NOT EOF-PYMTFILE
               PERFORM 3000-VALIDATE-PAYMENT
               IF FUNDS-OK
                   PERFORM 4000-UPDATE-BALANCE
                   ADD 1 TO WS-PYMT-COUNT
               ELSE
                   WRITE REJECTFILE-REC FROM ACCOUNT-RECORD
                   ADD 1 TO WS-REJECT-COUNT
               END-IF
           END-IF.

       3000-VALIDATE-PAYMENT.
           MOVE 'N' TO WS-SUFFICIENT-FUNDS
           CALL 'ACCTBAL' USING ACCOUNT-NUMBER
                                CUSTOMER-RECORD
                                WS-RETURN-CODE
           IF WS-RETURN-CODE = RC-SUCCESS
               COMPUTE WS-NEW-BALANCE =
                   CUSTOMER-BALANCE - PENDING-AMOUNT
               IF WS-NEW-BALANCE >= ZERO OR
                  WS-NEW-BALANCE >= CREDIT-LIMIT * -1
                   MOVE 'Y' TO WS-SUFFICIENT-FUNDS
               END-IF
           ELSE
               MOVE 'PYMT001'  TO ERR-PROGRAM-NAME
               MOVE '3000-VALIDATE-PAYMENT' TO ERR-PARAGRAPH
               MOVE 0100       TO ERR-CODE
               MOVE 'ACCTBAL CALL FAILED' TO ERR-MESSAGE
               CALL 'ERRHANDR' USING ERROR-RECORD
           END-IF.

       4000-UPDATE-BALANCE.
           MOVE WS-NEW-BALANCE  TO CUSTOMER-BALANCE
           MOVE TRANSACTION-DATE TO LAST-UPDATE-DATE
           CALL 'DBUPD01' USING ACCOUNT-NUMBER
                                CUSTOMER-RECORD
                                WS-RETURN-CODE
           IF WS-RETURN-CODE > RC-SUCCESS
               MOVE 'PYMT001'  TO ERR-PROGRAM-NAME
               MOVE '4000-UPDATE-BALANCE' TO ERR-PARAGRAPH
               MOVE 0200       TO ERR-CODE
               MOVE 'DATABASE UPDATE FAILED' TO ERR-MESSAGE
               CALL 'ERRHANDR' USING ERROR-RECORD
           END-IF.

       9000-END.
           CLOSE PYMTFILE
                 REJECTFILE
           MOVE WS-REJECT-COUNT TO TX-REJECT-COUNT
           MOVE WS-PYMT-COUNT   TO TX-SUCCESS-COUNT
           IF WS-REJECT-COUNT > ZERO
               MOVE RC-WARNING TO WS-RETURN-CODE
           ELSE
               MOVE RC-SUCCESS TO WS-RETURN-CODE
           END-IF
           STOP RUN.
