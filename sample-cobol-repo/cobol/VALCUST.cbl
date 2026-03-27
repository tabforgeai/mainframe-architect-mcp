      *----------------------------------------------------------------*
      * PROGRAM:  VALCUST                                             *
      * PURPOSE:  Customer Validation — existence and account status  *
      * AUTHOR:   TABFORGE-AI                                         *
      * CALLS:    DBREAD01, ERRHANDR                                  *
      * COPYBOOKS: CUSTMAST                                           *
      *----------------------------------------------------------------*
       IDENTIFICATION DIVISION.
       PROGRAM-ID.     VALCUST.
       AUTHOR.         TABFORGE-AI.
       DATE-WRITTEN.   2025-01-15.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-ZOS.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
           05  WS-PROGRAM-NAME        PIC X(8)  VALUE 'VALCUST'.
           05  WS-VALID-FLAG          PIC X(01) VALUE 'N'.
               88  CUSTOMER-IS-VALID      VALUE 'Y'.
           05  WS-CUST-FOUND          PIC X(01) VALUE 'N'.
               88  CUSTOMER-FOUND         VALUE 'Y'.
           05  WS-ACCT-STATUS         PIC X(02) VALUE SPACES.
           05  WS-VALIDATION-RC       PIC S9(04) COMP VALUE ZERO.
           05  WS-MSG-TEXT            PIC X(50) VALUE SPACES.

       COPY CUSTMAST.

       PROCEDURE DIVISION.

       1000-INIT.
           MOVE SPACES  TO WS-VALID-FLAG
           MOVE SPACES  TO WS-CUST-FOUND
           MOVE ZERO    TO WS-VALIDATION-RC
           PERFORM 2000-VALIDATE-CUST
           PERFORM 9000-END.

       2000-VALIDATE-CUST.
           CALL 'DBREAD01' USING CUSTOMER-ID
                                 CUSTOMER-RECORD
                                 WS-VALIDATION-RC
           IF WS-VALIDATION-RC NOT = ZERO
               MOVE 'Y' TO WS-CUST-FOUND
               PERFORM 2100-CHECK-ACCT-STATUS
           ELSE
               MOVE 'CUSTOMER NOT FOUND IN DATABASE' TO WS-MSG-TEXT
               MOVE 8 TO WS-VALIDATION-RC
               CALL 'ERRHANDR' USING ERROR-RECORD
           END-IF.

       2100-CHECK-ACCT-STATUS.
           MOVE CUSTOMER-STATUS TO WS-ACCT-STATUS
           IF CUSTOMER-STATUS = 'AC'
               PERFORM 2200-SET-VALID-FLAG
           ELSE
               MOVE 'CUSTOMER ACCOUNT NOT ACTIVE' TO WS-MSG-TEXT
               MOVE 4 TO WS-VALIDATION-RC
           END-IF.

       2200-SET-VALID-FLAG.
           MOVE 'Y' TO WS-VALID-FLAG
           MOVE ZERO TO WS-VALIDATION-RC.

       9000-END.
           STOP RUN.
