      *----------------------------------------------------------------*
      * TRANDATA - Transaction Summary Record                         *
      *----------------------------------------------------------------*
       01  TRANSACTION-SUMMARY.
           05  TRANS-PERIOD-FROM      PIC X(08).
           05  TRANS-PERIOD-TO        PIC X(08).
           05  TRANS-TOTAL-COUNT      PIC 9(07) COMP.
           05  TRANS-DEBIT-COUNT      PIC 9(07) COMP.
           05  TRANS-CREDIT-COUNT     PIC 9(07) COMP.
           05  TRANS-TOTAL-AMOUNT     PIC S9(13)V99 COMP-3.
           05  TRANS-DEBIT-AMOUNT     PIC S9(13)V99 COMP-3.
           05  TRANS-CREDIT-AMOUNT    PIC S9(13)V99 COMP-3.
           05  TRANS-AVG-AMOUNT       PIC S9(09)V99 COMP-3.
           05  TRANS-LARGEST-DEBIT    PIC S9(11)V99 COMP-3.
           05  TRANS-LARGEST-CREDIT   PIC S9(11)V99 COMP-3.
           05  TRANS-CURRENCY-CODE    PIC X(03).
