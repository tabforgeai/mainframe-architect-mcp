      *----------------------------------------------------------------*
      * PROGRAM:  DBUPD01                                             *
      * PURPOSE:  Generic Database Update Utility                     *
      * AUTHOR:   TABFORGE-AI                                         *
      * CALLS:    (none)                                              *
      * COPYBOOKS: CUSTMAST, ACCTDATA                                 *
      *----------------------------------------------------------------*
       IDENTIFICATION DIVISION.
       PROGRAM-ID.     DBUPD01.
       AUTHOR.         TABFORGE-AI.
       DATE-WRITTEN.   2025-01-15.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-ZOS.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT DBFILE   ASSIGN TO UT-S-DBFILE
                           ORGANIZATION IS INDEXED
                           ACCESS MODE  IS DYNAMIC
                           RECORD KEY   IS CUSTOMER-ID.

       DATA DIVISION.
       FILE SECTION.
       FD  DBFILE
           RECORDING MODE IS F
           RECORD CONTAINS 400 CHARACTERS.
       01  DBFILE-REC                 PIC X(400).

       WORKING-STORAGE SECTION.
           05  WS-PROGRAM-NAME        PIC X(8)  VALUE 'DBUPD01'.
           05  WS-UPD-STATUS          PIC X(02) VALUE SPACES.
           05  WS-RECORDS-UPDATED     PIC 9(07) COMP VALUE ZERO.
           05  WS-UPDATE-RC           PIC S9(04) COMP VALUE ZERO.
           05  WS-BEFORE-IMAGE        PIC X(400) VALUE SPACES.

       COPY CUSTMAST.
       COPY ACCTDATA.

       PROCEDURE DIVISION.

       1000-INIT.
           MOVE SPACES TO WS-UPD-STATUS
           MOVE ZERO   TO WS-UPDATE-RC
           OPEN I-O DBFILE
           PERFORM 2000-UPDATE-DB
           PERFORM 9000-END.

       2000-UPDATE-DB.
           MOVE CUSTOMER-RECORD TO WS-BEFORE-IMAGE
           READ DBFILE INTO CUSTOMER-RECORD
               KEY IS CUSTOMER-ID
               INVALID KEY
                   MOVE 8 TO WS-UPDATE-RC
               NOT INVALID KEY
                   PERFORM 2100-WRITE-RECORD
           END-READ.

       2100-WRITE-RECORD.
           REWRITE DBFILE-REC FROM CUSTOMER-RECORD
               INVALID KEY
                   MOVE 12 TO WS-UPDATE-RC
               NOT INVALID KEY
                   ADD 1 TO WS-RECORDS-UPDATED
                   MOVE ZERO TO WS-UPDATE-RC
           END-REWRITE.

       9000-END.
           CLOSE DBFILE
           STOP RUN.
