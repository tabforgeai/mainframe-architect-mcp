      *----------------------------------------------------------------*
      * CUSTMAST.CPY - Customer Master Record                         *
      * Used by: ACCTBAL, PYMT001, STMTPRT                           *
      *----------------------------------------------------------------*
       01  CUSTOMER-RECORD.
           05  CUSTOMER-ID            PIC X(10).
           05  CUSTOMER-NAME          PIC X(40).
           05  CUSTOMER-BALANCE       PIC S9(13)V99 COMP-3.
           05  CREDIT-LIMIT           PIC S9(11)V99 COMP-3.
           05  CURRENCY-CODE          PIC X(3).
           05  ACCOUNT-STATUS         PIC X(1).
               88  STATUS-ACTIVE          VALUE 'A'.
               88  STATUS-SUSPENDED       VALUE 'S'.
               88  STATUS-CLOSED          VALUE 'C'.
           05  LAST-UPDATE-DATE       PIC X(10).
           05  LAST-UPDATE-TIME       PIC X(8).
           05  CUSTOMER-SEGMENT       PIC X(2).
               88  SEG-RETAIL             VALUE 'RT'.
               88  SEG-CORPORATE          VALUE 'CO'.
               88  SEG-PRIVATE            VALUE 'PB'.
           05  FILLER                 PIC X(5).
