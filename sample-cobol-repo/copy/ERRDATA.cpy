      *----------------------------------------------------------------*
      * ERRDATA.CPY - Error and Return Code Definitions               *
      * Used by: ACCTBAL, PYMT001, STMTPRT, ERRHANDR                 *
      *----------------------------------------------------------------*
       01  ERROR-RECORD.
           05  ERR-PROGRAM-NAME       PIC X(8).
           05  ERR-PARAGRAPH          PIC X(30).
           05  ERR-CODE               PIC 9(4).
           05  ERR-MESSAGE            PIC X(80).
           05  ERR-TIMESTAMP          PIC X(26).
           05  ERR-SEVERITY           PIC X(1).
               88  SEV-INFO               VALUE 'I'.
               88  SEV-WARNING            VALUE 'W'.
               88  SEV-ERROR              VALUE 'E'.
               88  SEV-ABEND              VALUE 'A'.

       01  RETURN-CODES.
           05  RC-SUCCESS             PIC 9(4) VALUE 0000.
           05  RC-WARNING             PIC 9(4) VALUE 0004.
           05  RC-ERROR               PIC 9(4) VALUE 0008.
           05  RC-ABEND               PIC 9(4) VALUE 0012.
           05  WS-RETURN-CODE         PIC 9(4) VALUE ZERO.
