      *----------------------------------------------------------------*
      * LOANDATA - Loan Master Record                                 *
      *----------------------------------------------------------------*
       01  LOAN-RECORD.
           05  LOAN-ID                PIC X(12).
           05  LOAN-TYPE              PIC X(04).
               88  LOAN-PERSONAL          VALUE 'PERS'.
               88  LOAN-MORTGAGE          VALUE 'MORT'.
               88  LOAN-VEHICLE           VALUE 'VEHI'.
           05  LOAN-STATUS            PIC X(02).
               88  LOAN-ACTIVE            VALUE 'AC'.
               88  LOAN-CLOSED            VALUE 'CL'.
               88  LOAN-DEFAULTED         VALUE 'DF'.
           05  LOAN-AMOUNT            PIC S9(11)V99 COMP-3.
           05  LOAN-BALANCE           PIC S9(11)V99 COMP-3.
           05  LOAN-INTEREST-RATE     PIC S9(03)V9(4) COMP-3.
           05  LOAN-START-DATE        PIC X(08).
           05  LOAN-END-DATE          PIC X(08).
           05  LOAN-MONTHLY-PAYMENT   PIC S9(09)V99 COMP-3.
           05  LOAN-PAYMENTS-MADE     PIC 9(04) COMP.
           05  LOAN-PAYMENTS-DUE      PIC 9(04) COMP.
           05  LOAN-NEXT-DUE-DATE     PIC X(08).
           05  LOAN-OFFICER-ID        PIC X(08).
