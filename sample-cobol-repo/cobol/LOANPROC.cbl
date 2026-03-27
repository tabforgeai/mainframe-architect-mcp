      *----------------------------------------------------------------*
      * PROGRAM:  LOANPROC                                            *
      * PURPOSE:  CICS Loan Processing — application, approval, setup *
      * AUTHOR:   TABFORGE-AI                                         *
      * CALLS:    VALCUST, ACCTBAL, DBUPD01, ERRHANDR                 *
      * COPYBOOKS: CUSTMAST, ACCTDATA, LOANDATA                       *
      *----------------------------------------------------------------*
       IDENTIFICATION DIVISION.
       PROGRAM-ID.     LOANPROC.
       AUTHOR.         TABFORGE-AI.
       DATE-WRITTEN.   2025-02-15.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-ZOS.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT LOANFILE  ASSIGN TO UT-S-LOANFILE
                            ORGANIZATION IS INDEXED
                            ACCESS MODE  IS DYNAMIC
                            RECORD KEY   IS LOAN-ID.
           SELECT AUDITFILE ASSIGN TO UT-S-AUDITFILE
                            ORGANIZATION IS SEQUENTIAL
                            ACCESS MODE  IS SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD  LOANFILE
           RECORDING MODE IS F
           RECORD CONTAINS 300 CHARACTERS.
       01  LOANFILE-REC               PIC X(300).

       FD  AUDITFILE
           RECORDING MODE IS F
           RECORD CONTAINS 200 CHARACTERS.
       01  AUDITFILE-REC              PIC X(200).

       WORKING-STORAGE SECTION.
           05  WS-PROGRAM-NAME        PIC X(8)  VALUE 'LOANPROC'.
           05  WS-LOAN-ID             PIC X(12) VALUE SPACES.
           05  WS-LOAN-STATUS         PIC X(02) VALUE SPACES.
           05  WS-CREDIT-SCORE        PIC 9(03) COMP VALUE ZERO.
           05  WS-MAX-LOAN-AMT        PIC S9(11)V99 COMP-3 VALUE ZERO.
           05  WS-MONTHLY-PMT         PIC S9(09)V99 COMP-3 VALUE ZERO.
           05  WS-LOAN-TERM           PIC 9(03) COMP VALUE ZERO.
           05  WS-INTEREST-RATE       PIC S9(03)V9(4) COMP-3 VALUE ZERO.
           05  WS-TOTAL-INTEREST      PIC S9(11)V99 COMP-3 VALUE ZERO.
           05  WS-APPROVAL-FLAG       PIC X(01) VALUE 'N'.
               88  LOAN-APPROVED          VALUE 'Y'.
               88  LOAN-DENIED            VALUE 'N'.
           05  WS-DENIAL-CODE         PIC X(04) VALUE SPACES.
           05  WS-PROCESS-RC          PIC S9(04) COMP VALUE ZERO.
           05  WS-AUTH-TOKEN          PIC X(64) VALUE SPACES.
           05  WS-SOCIAL-SEC-NUM      PIC X(11) VALUE SPACES.
           05  WS-EXISTING-BALANCE    PIC S9(13)V99 COMP-3 VALUE ZERO.
           05  WS-DEBT-RATIO          PIC S9(03)V99 COMP-3 VALUE ZERO.
           05  WS-MIN-CREDIT-SCORE    PIC 9(03) COMP VALUE 650.
           05  WS-MAX-DEBT-RATIO      PIC S9(03)V99 COMP-3 VALUE 0.43.

       COPY CUSTMAST.
       COPY ACCTDATA.
       COPY LOANDATA.

       PROCEDURE DIVISION.

       1000-INIT.
           MOVE 'LOANPROC' TO WS-PROGRAM-NAME
           MOVE SPACES TO WS-LOAN-STATUS
           MOVE 'N'    TO WS-APPROVAL-FLAG
           MOVE ZERO   TO WS-PROCESS-RC
           OPEN I-O    LOANFILE
           OPEN OUTPUT AUDITFILE
           PERFORM 2000-VALIDATE-REQUEST
           PERFORM 9000-END.

       2000-VALIDATE-REQUEST.
           CALL 'VALCUST' USING CUSTOMER-ID
                                CUSTOMER-RECORD
                                WS-PROCESS-RC
           IF WS-PROCESS-RC NOT = ZERO
               MOVE 'LOANPROC'  TO ERR-PROGRAM-NAME
               MOVE '2000-VALIDATE-REQUEST' TO ERR-PARAGRAPH
               CALL 'ERRHANDR' USING ERROR-RECORD
               MOVE 'CUST' TO WS-DENIAL-CODE
               GO TO 9000-END
           END-IF
           PERFORM 2100-CHECK-ELIGIBILITY.

       2100-CHECK-ELIGIBILITY.
           MOVE CUSTOMER-CREDIT-SCORE TO WS-CREDIT-SCORE
           IF WS-CREDIT-SCORE < WS-MIN-CREDIT-SCORE
               MOVE 'CRED' TO WS-DENIAL-CODE
               MOVE 'N'    TO WS-APPROVAL-FLAG
               GO TO 2600-GENERATE-DOCS
           END-IF
           PERFORM 2200-CALC-LOAN-TERMS
           PERFORM 2300-VERIFY-BALANCE.

       2200-CALC-LOAN-TERMS.
           MOVE LOAN-INTEREST-RATE TO WS-INTEREST-RATE
           MOVE LOAN-AMOUNT        TO AVAILABLE-BALANCE
           COMPUTE WS-MONTHLY-PMT =
               LOAN-AMOUNT * WS-INTEREST-RATE / 12
               / (1 - (1 + WS-INTEREST-RATE / 12)
               ** (-LOAN-PAYMENTS-DUE))
           COMPUTE WS-TOTAL-INTEREST =
               WS-MONTHLY-PMT * LOAN-PAYMENTS-DUE - LOAN-AMOUNT
           COMPUTE WS-MAX-LOAN-AMT =
               CUSTOMER-INCOME * 4.5.

       2300-VERIFY-BALANCE.
           CALL 'ACCTBAL' USING CUSTOMER-ID
                                ACCOUNT-RECORD
                                WS-PROCESS-RC
           MOVE AVAILABLE-BALANCE TO WS-EXISTING-BALANCE
           IF WS-PROCESS-RC NOT = ZERO
               MOVE 'LOANPROC'  TO ERR-PROGRAM-NAME
               MOVE '2300-VERIFY-BALANCE' TO ERR-PARAGRAPH
               CALL 'ERRHANDR' USING ERROR-RECORD
           END-IF
           COMPUTE WS-DEBT-RATIO =
               (WS-MONTHLY-PMT + PENDING-AMOUNT) / CUSTOMER-INCOME
           IF WS-DEBT-RATIO > WS-MAX-DEBT-RATIO
               MOVE 'DEBT' TO WS-DENIAL-CODE
               MOVE 'N'    TO WS-APPROVAL-FLAG
           ELSE
               MOVE 'Y'    TO WS-APPROVAL-FLAG
               PERFORM 2400-CREATE-LOAN-RECORD
           END-IF.

       2400-CREATE-LOAN-RECORD.
           MOVE 'AC'        TO LOAN-STATUS
           MOVE LOAN-AMOUNT TO LOAN-BALANCE
           WRITE LOANFILE-REC FROM LOAN-RECORD
               INVALID KEY
                   MOVE 8 TO WS-PROCESS-RC
                   MOVE 'LOANPROC'  TO ERR-PROGRAM-NAME
                   CALL 'ERRHANDR' USING ERROR-RECORD
           END-WRITE
           PERFORM 2500-UPDATE-ACCOUNT.

       2500-UPDATE-ACCOUNT.
           ADD LOAN-AMOUNT TO AVAILABLE-BALANCE
           CALL 'DBUPD01' USING CUSTOMER-ID
                                ACCOUNT-RECORD
                                WS-PROCESS-RC
           IF WS-PROCESS-RC NOT = ZERO
               MOVE 'LOANPROC'  TO ERR-PROGRAM-NAME
               MOVE '2500-UPDATE-ACCOUNT' TO ERR-PARAGRAPH
               CALL 'ERRHANDR' USING ERROR-RECORD
           END-IF.

       2600-GENERATE-DOCS.
           WRITE AUDITFILE-REC FROM LOAN-RECORD.

       9000-END.
           CLOSE LOANFILE
                 AUDITFILE
           STOP RUN.
