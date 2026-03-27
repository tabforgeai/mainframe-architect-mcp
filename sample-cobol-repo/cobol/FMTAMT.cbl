      *----------------------------------------------------------------*
      * PROGRAM:  FMTAMT                                              *
      * PURPOSE:  Amount Formatting Utility — numeric to display fmt  *
      * AUTHOR:   TABFORGE-AI                                         *
      * CALLS:    (none)                                              *
      * COPYBOOKS: ACCTDATA                                           *
      *----------------------------------------------------------------*
       IDENTIFICATION DIVISION.
       PROGRAM-ID.     FMTAMT.
       AUTHOR.         TABFORGE-AI.
       DATE-WRITTEN.   2025-01-15.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-ZOS.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
           05  WS-PROGRAM-NAME        PIC X(8)  VALUE 'FMTAMT'.
           05  WS-INPUT-AMOUNT        PIC S9(13)V99 COMP-3.
           05  WS-OUTPUT-AMOUNT       PIC X(18) VALUE SPACES.
           05  WS-AMT-WORK            PIC ZZ,ZZZ,ZZZ,ZZZ.99-.
           05  WS-CURRENCY-SYM        PIC X(03) VALUE 'EUR'.
           05  WS-FORMAT-RC           PIC S9(04) COMP VALUE ZERO.
           05  WS-NEGATIVE-FLAG       PIC X(01) VALUE 'N'.

       COPY ACCTDATA.

       PROCEDURE DIVISION.

       1000-INIT.
           MOVE SPACES TO WS-OUTPUT-AMOUNT
           MOVE ZERO   TO WS-FORMAT-RC
           PERFORM 2000-FORMAT-AMOUNT
           PERFORM 9000-END.

       2000-FORMAT-AMOUNT.
           IF WS-INPUT-AMOUNT < ZERO
               MOVE 'Y' TO WS-NEGATIVE-FLAG
           ELSE
               MOVE 'N' TO WS-NEGATIVE-FLAG
           END-IF
           MOVE WS-INPUT-AMOUNT TO WS-AMT-WORK
           STRING WS-CURRENCY-SYM ' '
                  WS-AMT-WORK
                  DELIMITED SIZE
                  INTO WS-OUTPUT-AMOUNT.

       9000-END.
           STOP RUN.
