      *----------------------------------------------------------------*
      * PROGRAM:  CUSTINQ                                             *
      * PURPOSE:  CICS Customer Inquiry — online customer lookup      *
      * AUTHOR:   TABFORGE-AI                                         *
      * CALLS:    VALCUST, DBREAD01, ERRHANDR                         *
      * COPYBOOKS: CUSTMAST, ADDRDATA                                 *
      *----------------------------------------------------------------*
       IDENTIFICATION DIVISION.
       PROGRAM-ID.     CUSTINQ.
       AUTHOR.         TABFORGE-AI.
       DATE-WRITTEN.   2025-02-01.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-ZOS.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
           05  WS-PROGRAM-NAME        PIC X(8)  VALUE 'CUSTINQ'.
           05  WS-CUST-ID             PIC X(10) VALUE SPACES.
           05  WS-INQUIRY-RC          PIC S9(04) COMP VALUE ZERO.
           05  WS-ADDR-FOUND          PIC X(01) VALUE 'N'.
               88  ADDRESS-FOUND          VALUE 'Y'.
           05  WS-RESP-CODE           PIC S9(08) COMP VALUE ZERO.
           05  WS-RESP2-CODE          PIC S9(08) COMP VALUE ZERO.
           05  WS-COMMAREA-LEN        PIC S9(04) COMP VALUE 200.
           05  WS-PIN-NUMBER          PIC X(06) VALUE SPACES.
           05  WS-SESSION-TOKEN       PIC X(32) VALUE SPACES.

       COPY CUSTMAST.
       COPY ADDRDATA.

       PROCEDURE DIVISION.

       1000-INIT.
           MOVE SPACES TO WS-CUST-ID
           MOVE ZERO   TO WS-INQUIRY-RC
           MOVE SPACES TO WS-ADDR-FOUND
           PERFORM 2000-GET-CUSTOMER
           PERFORM 9000-END.

       2000-GET-CUSTOMER.
           CALL 'VALCUST' USING CUSTOMER-ID
                                CUSTOMER-RECORD
                                WS-INQUIRY-RC
           IF WS-INQUIRY-RC = ZERO
               PERFORM 2100-GET-ADDRESS
               PERFORM 2200-BUILD-RESPONSE
           ELSE
               MOVE 'CUSTINQ'  TO ERR-PROGRAM-NAME
               MOVE '2000-GET-CUSTOMER' TO ERR-PARAGRAPH
               CALL 'ERRHANDR' USING ERROR-RECORD
           END-IF.

       2100-GET-ADDRESS.
           CALL 'DBREAD01' USING CUSTOMER-ID
                                 ADDRESS-RECORD
                                 WS-INQUIRY-RC
           IF WS-INQUIRY-RC = ZERO
               MOVE 'Y' TO WS-ADDR-FOUND
           ELSE
               MOVE SPACES TO ADDRESS-RECORD
           END-IF.

       2200-BUILD-RESPONSE.
           MOVE CUSTOMER-ID   TO WS-CUST-ID
           MOVE ZERO TO WS-RESP-CODE.

       9000-END.
           STOP RUN.
