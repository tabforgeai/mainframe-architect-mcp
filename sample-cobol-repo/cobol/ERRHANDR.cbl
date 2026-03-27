      *----------------------------------------------------------------*
      * PROGRAM:  ERRHANDR                                             *
      * PURPOSE:  Centralized Error Handler and Logger                 *
      * AUTHOR:   TABFORGE-AI                                          *
      * CALLS:    (none - terminal error handler)                      *
      * COPYBOOKS: ERRDATA                                             *
      *----------------------------------------------------------------*
       IDENTIFICATION DIVISION.
       PROGRAM-ID.     ERRHANDR.
       AUTHOR.         TABFORGE-AI.
       DATE-WRITTEN.   2025-01-10.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-ZOS.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT ERRLOGFILE ASSIGN TO UT-S-ERRLOGFILE
                             ORGANIZATION IS SEQUENTIAL
                             ACCESS MODE  IS SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD  ERRLOGFILE
           RECORDING MODE IS F
           RECORD CONTAINS 200 CHARACTERS.
       01  ERRLOGFILE-REC             PIC X(200).

       WORKING-STORAGE SECTION.
           05  WS-PROGRAM-NAME        PIC X(8)  VALUE 'ERRHANDR'.
           05  WS-LOG-INITIALIZED     PIC X(1)  VALUE 'N'.
               88  LOG-INITIALIZED        VALUE 'Y'.
           05  WS-LOG-LINE            PIC X(200).
           05  WS-TIMESTAMP           PIC X(26).
           05  WS-LOG-COUNT           PIC 9(7)  COMP VALUE ZERO.
           05  WS-ABEND-COUNT         PIC 9(5)  COMP VALUE ZERO.

       COPY ERRDATA.

       LINKAGE SECTION.
       01  LK-ERROR-RECORD.
           05  LK-PROGRAM-NAME        PIC X(8).
           05  LK-PARAGRAPH           PIC X(30).
           05  LK-ERR-CODE            PIC 9(4).
           05  LK-MESSAGE             PIC X(80).
           05  LK-TIMESTAMP           PIC X(26).
           05  LK-SEVERITY            PIC X(1).

       PROCEDURE DIVISION USING LK-ERROR-RECORD.

       1000-INIT.
           IF NOT LOG-INITIALIZED
               OPEN EXTEND ERRLOGFILE
               MOVE 'Y' TO WS-LOG-INITIALIZED
           END-IF
           PERFORM 2000-LOG-ERROR
           IF LK-SEVERITY = SEV-ABEND
               ADD 1 TO WS-ABEND-COUNT
               PERFORM 3000-HANDLE-ABEND
           END-IF
           GOBACK.

       2000-LOG-ERROR.
           ADD 1 TO WS-LOG-COUNT
           MOVE SPACES TO WS-LOG-LINE
           STRING LK-TIMESTAMP   DELIMITED SIZE
                  ' ['           DELIMITED SIZE
                  LK-SEVERITY    DELIMITED SIZE
                  '] PGM='       DELIMITED SIZE
                  LK-PROGRAM-NAME DELIMITED SIZE
                  ' PARA='       DELIMITED SIZE
                  LK-PARAGRAPH   DELIMITED SIZE
                  ' RC='         DELIMITED SIZE
                  LK-ERR-CODE    DELIMITED SIZE
                  ' MSG='        DELIMITED SIZE
                  LK-MESSAGE     DELIMITED SIZE
                  INTO WS-LOG-LINE
           WRITE ERRLOGFILE-REC FROM WS-LOG-LINE.

       3000-HANDLE-ABEND.
           MOVE SPACES TO WS-LOG-LINE
           STRING '*** ABEND DETECTED IN: ' DELIMITED SIZE
                  LK-PROGRAM-NAME            DELIMITED SIZE
                  ' - SYSTEM NOTIFIED ***'   DELIMITED SIZE
                  INTO WS-LOG-LINE
           WRITE ERRLOGFILE-REC FROM WS-LOG-LINE
           CLOSE ERRLOGFILE.

       9000-END.
           CLOSE ERRLOGFILE
           GOBACK.
