      *----------------------------------------------------------------*
      * PROGRAM:  LEGACY99                                            *
      * PURPOSE:  OLD ACCOUNT RECONCILIATION — DEPRECATED 2019       *
      * AUTHOR:   ORIGINAL-DEV                                        *
      * CALLS:    (none)                                              *
      * COPYBOOKS: CUSTMAST                                           *
      * NOTE:     THIS PROGRAM IS NO LONGER CALLED BY ANY JOB        *
      *           KEPT FOR REFERENCE ONLY — CANDIDATE FOR REMOVAL     *
      *----------------------------------------------------------------*
       IDENTIFICATION DIVISION.
       PROGRAM-ID.     LEGACY99.
       AUTHOR.         ORIGINAL-DEV.
       DATE-WRITTEN.   2019-03-01.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-ZOS.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT OLDFILE  ASSIGN TO UT-S-OLDFILE
                           ORGANIZATION IS SEQUENTIAL
                           ACCESS MODE  IS SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD  OLDFILE
           RECORDING MODE IS F
           RECORD CONTAINS 200 CHARACTERS.
       01  OLDFILE-REC                PIC X(200).

       WORKING-STORAGE SECTION.
           05  WS-PROGRAM-NAME        PIC X(8)  VALUE 'LEGACY99'.
           05  WS-OLD-STATUS          PIC X(02) VALUE SPACES.
           05  WS-LEGACY-RC           PIC S9(04) COMP VALUE ZERO.
           05  WS-REC-COUNT           PIC 9(07) COMP VALUE ZERO.

       COPY CUSTMAST.

       PROCEDURE DIVISION.

       1000-INIT.
           MOVE SPACES TO WS-OLD-STATUS
           MOVE ZERO   TO WS-LEGACY-RC
           OPEN INPUT OLDFILE
           PERFORM 2000-OLD-PROCESS UNTIL WS-OLD-STATUS = 'EN'
           PERFORM 9000-END.

       2000-OLD-PROCESS.
           READ OLDFILE INTO CUSTOMER-RECORD
               AT END MOVE 'EN' TO WS-OLD-STATUS
           END-READ
           IF WS-OLD-STATUS NOT = 'EN'
               ADD 1 TO WS-REC-COUNT
           END-IF.

       9000-END.
           CLOSE OLDFILE
           STOP RUN.
