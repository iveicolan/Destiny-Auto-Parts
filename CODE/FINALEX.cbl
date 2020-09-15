       IDENTIFICATION DIVISION.
       PROGRAM-ID. FINALEX.
      ******************************************************************
      * INSERT HERE WHAT THE PROGRAM DOES
      ******************************************************************

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
      * Input File PARTSUPP with the data records
           SELECT PARTSUPPIN ASSIGN TO PARTSUPP
           FILE STATUS IS IN-PARTSUPP-KEY.

      * Input File STATEZIP with StateName, Acronym, and zipcode range
           SELECT STATEZIP ASSIGN TO STATEZIP
           FILE STATUS IS IN-STATEZIP-KEY.

      * Output File for errors
           SELECT ERRORFILE ASSIGN TO ERRFILE
           FILE STATUS IS OUT-ERRORFILE-KEY.

      * HERE declare the other 3 output files PARTS, ADDRESS, PURCHASE>>

       DATA DIVISION.
       FILE SECTION.
       FD  PARTSUPPIN
           RECORDING MODE IS F
           LABEL RECORDS ARE STANDARD
           RECORD CONTAINS 473 CHARACTERS
           BLOCK CONTAINS 0 RECORDS
           DATA RECORD IS PARTSUPPIN-REC.
       01  PARTSUPPIN-REC     PIC X(473).

       FD  STATEZIP
           RECORDING MODE IS F
           LABEL RECORDS ARE STANDARD
           RECORD CONTAINS 33 CHARACTERS
           BLOCK CONTAINS 0 RECORDS
           DATA RECORD IS STATEZIP-REC.
       01  STATEZIP-REC     PIC X(33).

        FD ERRORFILE
           RECORDING MODE IS F
           LABEL RECORDS ARE STANDARD
           RECORD CONTAINS 80 CHARACTERS
           BLOCK CONTAINS 0 RECORDS
           DATA RECORD IS ERRORFILE-REC.
          01  ERRORFILE-REC PIC X(80).

       WORKING-STORAGE SECTION.
           COPY PARTS. *>Parts Copybook
           COPY PARTSUB. *> PART-SUPP-ADDR-PO Copybook
           COPY PRCHSORD. *>PURCHASE-ORDERS Copybook
           COPY SUPADDRS. *>SUPP-ADDRESS Copybook
           COPY SUPPLIER. *>Suppliers Copybook

       01 FILE-STATUS-CODES.
      * Here we need to add FILES STATUS CODES of the other output files
      * for output files PARTS, ADDRESS, PURCHASE

      * File status key for input File PARTSUPP
           05 IN-PARTSUPP-KEY           PIC X(2).
                88 CODE-WRITE               VALUE SPACES.

      * File status key for input File STATEZIP
           05 IN-STATEZIP-KEY           PIC X(2).
                88 CODE-WRITE               VALUE SPACES.

      * File status key for Output ErrorFile
           05 OUT-ERRORFILE-KEY          PIC X(2).
                88 CODE-WRITE               VALUE SPACES.
       01 PARTSUPPIN-EOF-WS                  PIC X(01) VALUE 'N'.
           88 END-OF-FILE VALUE 'Y'.


      * Internal VARIABLE GROUP FOR PART-SUPP-ADDR-PO Copybook
       01  WS-PART-SUPP-ADDR-PO-OUT.
           05 PARTS-OUT.
               10  PART-NUMBER       PIC X(23) VALUE SPACES.
               10  PART-NAME         PIC X(14) VALUE SPACES.
               10  SPEC-NUMBER       PIC X(07) VALUE SPACES.
               10  GOVT-COMML-CODE   PIC X(01) VALUE SPACES.
               10  BLUEPRINT-NUMBER  PIC X(10) VALUE SPACES.
               10  UNIT-OF-MEASURE   PIC X(03) VALUE SPACES.
               10  WEEKS-LEAD-TIME   PIC 9(03) VALUE ZERO.
               10  VEHICLE-MAKE      PIC X(03) VALUE SPACES.
                    88 CHRYSLER       VALUE 'CHR'.
                    88 FORD           VALUE 'FOR'.
                    88 GM             VALUE 'GM '.
                    88 VOLKSWAGON     VALUE 'VW '.
                    88 TOYOTA         VALUE 'TOY'.
                    88 JAGUAR         VALUE 'JAG'.
                    88 PEUGEOT        VALUE 'PEU'.
                    88 BMW            VALUE 'BMW'.
               10  VEHICLE-MODEL     PIC X(10) VALUE SPACES.
               10  VEHICLE-YEAR      PIC X(04) VALUE '0000'.
               10  FILLER            PIC X(14) VALUE SPACES.
           05 SUPPLIERS-OUT.
               10  SUPPLIER-CODE     PIC X(10) VALUE SPACES.
               10  SUPPLIER-TYPE     PIC X(01) VALUE SPACES.
                    88 SUBCONTRACTOR  VALUE 'S'.
                    88 DISTRIBUTOR    VALUE 'D'.
                    88 MANUFACTURER   VALUE 'M'.
                    88 IMPORTER       VALUE 'I'.
               10  SUPPLIER-NAME     PIC X(15) VALUE SPACES.
               10  SUPPLIER-PERF     PIC 9(03) VALUE ZERO.
               10  SUPPLIER-RATING   PIC X(01) VALUE SPACES.
                    88 HIGHEST-QUALITY VALUE '3'.
                    88 AVERAGE-QUALITY VALUE '2'.
                    88 LOWEST-QUALITY  VALUE '1'.
               10  SUPPLIER-STATUS   PIC X(01) VALUE SPACES.
                    88 GOVT-COMM       VALUE '1'.
                    88 GOVT-ONLY       VALUE '2'.
                    88 COMMERCIAL-ONLY VALUE '3'.
               10  SUPPLIER-ACT-DATE PIC 9(08) VALUE ZERO.
           05 SUPP-ADDRESS-OUT OCCURS 3 TIMES INDEXED BY ADDR-IDX.
               10 ADDRESS-TYPE      PIC X(01) VALUE SPACES.
                  88 ORDER-ADDRESS           VALUE '1'.
                  88 SCHED-ADDRESS           VALUE '2'.
                  88 REMIT-ADDRESS           VALUE '3'.
               10 ADDRESS-1         PIC X(15) VALUE SPACES.
               10 ADDRESS-2         PIC X(15) VALUE SPACES.
               10 ADDRESS-3         PIC X(15) VALUE SPACES.
               10 CITY              PIC X(15) VALUE SPACES.
               10 ADDR-STATE        PIC X(02) VALUE SPACES.
               10 ZIP-CODE          PIC 9(10) VALUE ZERO.
           05 PURCHASE-ORDER-OUT OCCURS 3 TIMES INDEXED BY PO-IDX.
               10  PO-NUMBER         PIC X(06) VALUE SPACES.
               10  BUYER-CODE        PIC X(03) VALUE SPACES.
               10  QUANTITY          PIC S9(7) VALUE ZERO.
               10  UNIT-PRICE        PIC S9(7)V99 VALUE ZERO.
               10  ORDER-DATE        PIC 9(08) VALUE ZERO.
               10  DELIVERY-DATE     PIC 9(08) VALUE ZERO.



      *Counter of records readed from PARTSUPPIN file:
       01 WS-IN-PARTSUPP-CTR               PIC 9(7) VALUE ZERO.



       PROCEDURE DIVISION.

       MAIN.
           PERFORM 000-HOUSEKEEPING.
           PERFORM 100-Main2 UNTIL PARTSUPPIN-EOF-WS = 'Y'.
           PERFORM 600-CLOSE-FILES.
           GOBACK.

       000-Housekeeping.
      * Initialization Routine
           INITIALIZE PART-SUPP-ADDR-PO, WS-PART-SUPP-ADDR-PO-OUT.
      * Priming Read
           PERFORM 300-Open-Files.
           PERFORM 400-Read-PARTSUPPIN.


       100-Main2.
      *    DISPLAY '100-Main'.
           PERFORM 200-PROCESS-DATA.
           PERFORM 500-Write-ERRORFILE.
           PERFORM 400-Read-PARTSUPPIN.


       200-PROCESS-DATA.
      * From PARTSUPPIN file
           MOVE PARTS  TO PARTS-OUT.
           MOVE SUPPLIERS    TO SUPPLIERS-OUT.
           MOVE SUPP-ADDRESS     TO SUPP-ADDRESS-OUT.
           MOVE PURCHASE-ORDER     TO PURCHASE-ORDER-OUT.


       300-Open-Files.
      *    DISPLAY '300-OPEN-FILES'.
           OPEN INPUT PARTSUPPIN.
      *    Input File Status Checking for PARTSUPPIN File
           IF IN-PARTSUPP-KEY NOT = '00' THEN
                DISPLAY
                        '---------------------------------------------'
                DISPLAY 'File Problem openning Input PARTSUPPIN File'
                GO TO 2000-ABEND-RTN
           END-IF.
           OPEN INPUT STATEZIP.
      *    Input File Status Checking for STATEZIP file
           IF IN-STATEZIP-KEY NOT = '00' THEN
                DISPLAY
                        '---------------------------------------------'
                DISPLAY 'File Problem openning Input STATEZIP File'
                GO TO 2000-ABEND-RTN
           END-IF.
           OPEN OUTPUT ERRORFILE.
      *    Output File Status Checking for ERRORFILE
           IF OUT-ERRORFILE-KEY NOT = '00' THEN
                DISPLAY
                        '---------------------------------------------'
                DISPLAY 'File Problem openning ERRORFILE'
                GO TO 2000-ABEND-RTN
           END-IF.



       400-Read-PARTSUPPIN.
           READ PARTSUPPIN INTO PART-SUPP-ADDR-PO
      * Set AT END Switch
                AT END MOVE "Y" TO PARTSUPPIN-EOF-WS
                IF IN-PARTSUPP-KEY  = '00' THEN
                    DISPLAY
                        '---------------------------------------------'
                    DISPLAY 'Input file PARTSUPPIN reading problem'
                    PERFORM 2000-ABEND-RTN
                END-IF
           END-READ.
      * To count number of records readed from PARTSUPPPIN file.
           IF (NOT END-OF-FILE) THEN ADD +1 TO WS-IN-PARTSUPP-CTR
           END-IF.


       500-Write-ERRORFILE.
      *    DISPLAY 'WRITE ERRORFILE: '.
           WRITE ERRORFILE-REC FROM WS-PART-SUPP-ADDR-PO-OUT.
           IF OUT-ERRORFILE-KEY NOT EQUAL ZERO THEN
                DISPLAY 'Output ERRORfile writing problem'
                PERFORM 2000-ABEND-RTN
           END-IF.

       600-CLOSE-FILES.
      *     DISPLAY 'CLOSING FILES'.
           CLOSE  PARTSUPPIN, STATEZIP, ERRORFILE.


       2000-ABEND-RTN.
           DISPLAY 'PROGRAM ENCOUNTERED AN ERROR'.
           EXIT.


