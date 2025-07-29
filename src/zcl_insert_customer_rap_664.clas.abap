CLASS zcl_insert_customer_rap_664 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_insert_customer_rap_664 IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
* Clean up records in persistence and draft tables
    DELETE FROM zcustomers_664.
    DELETE FROM zcustomers_d_664.

* Inserting records into the persistence table
    INSERT zcustomers_664 FROM (
    SELECT FROM /dmo/travel
           FIELDS uuid( ) AS customer_uuid,
           customer_id,
           description,
           createdby AS local_created_by,
           createdat AS local_created_at,
           lastchangedby AS local_last_changed_by,
           lastchangedat AS local_last_changed_at
    WHERE travel_id LE 1000 ).

    IF sy-subrc EQ 0.
      out->write( |Customers inserted: { sy-dbcnt } .| ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
