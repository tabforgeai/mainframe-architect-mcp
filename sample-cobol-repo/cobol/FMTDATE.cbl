      *----------------------------------------------------------------*
      * PROGRAM:  FMTDATE                                             *
      * PURPOSE:  Date Formatting Utility — YYYYMMDD to display fmt   *
      * AUTHOR:   TABFORGE-AI                                         *
      * CALLS:    (none)                                              *
      * COPYBOOKS: (none)                                             *
      *----------------------------------------------------------------*
       IDENTIFICATION DIVISION.
       PROGRAM-ID.     FMTDATE.
       AUTHOR.         TABFORGE-AI.
       DATE-WRITTEN.   2025-01-15.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-ZOS.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
           05  WS-PROGRAM-NAME        PIC X(8)  VALUE 'FMTDATE'.
           05  WS-INPUT-DATE          PIC X(08) VALUE SPACES.
           05  WS-OUTPUT-DATE         PIC X(10) VALUE SPACES.
           05  WS-DATE-WORK.
               10  WS-DATE-YYYY       PIC X(04).
               10  WS-DATE-MM         PIC X(02).
               10  WS-DATE-DD         PIC X(02).
           05  WS-DATE-FORMAT         PIC X(02) VALUE 'EU'.
               88  FORMAT-EU              VALUE 'EU'.
               88  FORMAT-US              VALUE 'US'.
           05  WS-FORMAT-RC           PIC S9(04) COMP VALUE ZERO.

       PROCEDURE DIVISION.

       1000-INIT.
           MOVE SPACES TO WS-OUTPUT-DATE
           MOVE ZERO   TO WS-FORMAT-RC
           PERFORM 2000-FORMAT-DATE
           PERFORM 9000-END.

       2000-FORMAT-DATE.
           MOVE WS-INPUT-DATE(1:4) TO WS-DATE-YYYY
           MOVE WS-INPUT-DATE(5:2) TO WS-DATE-MM
           MOVE WS-INPUT-DATE(7:2) TO WS-DATE-DD
           IF FORMAT-EU
               STRING WS-DATE-DD '.' WS-DATE-MM '.' WS-DATE-YYYY
                   DELIMITED SIZE INTO WS-OUTPUT-DATE
           ELSE
               STRING WS-DATE-MM '/' WS-DATE-DD '/' WS-DATE-YYYY
                   DELIMITED SIZE INTO WS-OUTPUT-DATE
           END-IF.

       9000-END.
           STOP RUN.
