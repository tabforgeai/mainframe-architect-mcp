      *----------------------------------------------------------------*
      * ACCTDATA.CPY - Account Transaction Data                       *
      * Used by: ACCTBAL, PYMT001                                     *
      *----------------------------------------------------------------*
       01  ACCOUNT-RECORD.
           05  ACCOUNT-NUMBER         PIC X(12).
           05  ACCOUNT-TYPE           PIC X(2).
               88  TYPE-CHECKING          VALUE 'CH'.
               88  TYPE-SAVINGS           VALUE 'SA'.
               88  TYPE-LOAN              VALUE 'LN'.
           05  AVAILABLE-BALANCE      PIC S9(13)V99 COMP-3.
           05  PENDING-AMOUNT         PIC S9(11)V99 COMP-3.
           05  TRANSACTION-DATE       PIC X(10).
           05  TRANSACTION-TIME       PIC X(8).
           05  TRANSACTION-TYPE       PIC X(3).
           05  TRANSACTION-REF        PIC X(16).
           05  CHANNEL-CODE           PIC X(4).
           05  FILLER                 PIC X(8).

       01  TRANSACTION-COUNTERS.
           05  TX-TOTAL-COUNT         PIC 9(7) COMP.
           05  TX-SUCCESS-COUNT       PIC 9(7) COMP.
           05  TX-REJECT-COUNT        PIC 9(7) COMP.
           05  TX-TOTAL-AMOUNT        PIC S9(15)V99 COMP-3.
