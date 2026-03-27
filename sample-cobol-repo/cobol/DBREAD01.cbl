      *----------------------------------------------------------------*
      * PROGRAM:  DBREAD01                                            *
      * PURPOSE:  Generic Database Read Utility                       *
      * AUTHOR:   TABFORGE-AI                                         *
      * CALLS:    (none)                                              *
      * COPYBOOKS: CUSTMAST, ACCTDATA                                 *
      *----------------------------------------------------------------*
       IDENTIFICATION DIVISION.
       PROGRAM-ID.     DBREAD01.
       AUTHOR.         TABFORGE-AI.
       DATE-WRITTEN.   2025-01-15.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-ZOS.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT DBFILE   ASSIGN TO UT-S-DBFILE
                           ORGANIZATION IS INDEXED
                           ACCESS MODE  IS RANDOM
                           RECORD KEY   IS CUSTOMER-ID.

       DATA DIVISION.
       FILE SECTION.
       FD  DBFILE
           RECORDING MODE IS F
           RECORD CONTAINS 400 CHARACTERS.
       01  DBFILE-REC                 PIC X(400).

       WORKING-STORAGE SECTION.
           05  WS-PROGRAM-NAME        PIC X(8)  VALUE 'DBREAD01'.
           05  WS-DB-STATUS           PIC X(02) VALUE SPACES.
           05  WS-RECORD-COUNT        PIC 9(07) COMP VALUE ZERO.
           05  WS-READ-RC             PIC S9(04) COMP VALUE ZERO.

       COPY CUSTMAST.
       COPY ACCTDATA.

       PROCEDURE DIVISION.

       1000-INIT.
           MOVE SPACES TO WS-DB-STATUS
           MOVE ZERO   TO WS-READ-RC
           OPEN INPUT DBFILE
           PERFORM 2000-READ-DB
           PERFORM 9000-END.

       2000-READ-DB.
           READ DBFILE INTO CUSTOMER-RECORD
               KEY IS CUSTOMER-ID
               INVALID KEY
                   MOVE 8 TO WS-READ-RC
               NOT INVALID KEY
                   ADD 1 TO WS-RECORD-COUNT
                   MOVE ZERO TO WS-READ-RC
           END-READ.

       9000-END.
           CLOSE DBFILE
           STOP RUN.
