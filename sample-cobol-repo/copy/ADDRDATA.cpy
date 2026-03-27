      *----------------------------------------------------------------*
      * ADDRDATA - Customer Address Data                              *
      *----------------------------------------------------------------*
       01  ADDRESS-RECORD.
           05  ADDR-LINE-1            PIC X(30).
           05  ADDR-LINE-2            PIC X(30).
           05  ADDR-CITY              PIC X(20).
           05  ADDR-STATE             PIC X(02).
           05  ADDR-ZIP               PIC X(10).
           05  ADDR-COUNTRY           PIC X(03).
           05  ADDR-VALID-FLAG        PIC X(01).
               88  ADDR-VALID             VALUE 'Y'.
               88  ADDR-INVALID           VALUE 'N'.
           05  ADDR-LAST-UPDATE       PIC X(08).
