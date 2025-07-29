CLASS lhc_ZDD_R_CUSTOMER_TRAVEL_664 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    CONSTANTS:
      BEGIN OF customer_travel_status,
        open     TYPE c LENGTH 1 VALUE 'O', " Open
        accepted TYPE c LENGTH 1 VALUE 'A', " Accepted
        rejected TYPE c LENGTH 1 VALUE 'X', " Rejected
      END OF customer_travel_status.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zdd_r_customer_travel_664 RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zdd_r_customer_travel_664 RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zdd_r_customer_travel_664 RESULT result.

    METHODS acceptClients FOR MODIFY
      IMPORTING keys FOR ACTION zdd_r_customer_travel_664~acceptClients RESULT result.

    METHODS rejectClients FOR MODIFY
      IMPORTING keys FOR ACTION zdd_r_customer_travel_664~rejectClients RESULT result.

    METHODS setDescription FOR DETERMINE ON SAVE
      IMPORTING keys FOR zdd_r_customer_travel_664~setDescription.

    METHODS validateCustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR zdd_r_customer_travel_664~validateCustomer.

ENDCLASS.

CLASS lhc_ZDD_R_CUSTOMER_TRAVEL_664 IMPLEMENTATION.

  METHOD get_instance_features.

* Get parameter discount percent
    READ ENTITIES OF zdd_r_customer_travel_664 IN LOCAL MODE
    ENTITY zdd_r_customer_travel_664
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_root_entity)
    FAILED failed.

* Change the action behavior by status
    result = VALUE #(
    FOR ls_root_entity IN lt_root_entity ( %tky = ls_root_entity-%tky
    %action-acceptClients = COND #( WHEN ls_root_entity-OverallStatus = customer_travel_status-open
                                    THEN if_abap_behv=>fc-o-enabled
                                    ELSE if_abap_behv=>fc-o-disabled )
    %action-rejectClients = COND #( WHEN ls_root_entity-OverallStatus = customer_travel_status-open
                                    THEN if_abap_behv=>fc-o-enabled
                                    ELSE if_abap_behv=>fc-o-disabled )
                                    ) ).


  ENDMETHOD.

  METHOD get_instance_authorizations.

* Declaration of necessary variables
    DATA: lv_update_requested TYPE abap_bool,
          lv_update_granted   TYPE abap_bool,
          lv_delete_requested TYPE abap_bool,
          lv_delete_granted   TYPE abap_bool.

* Read root entity entries updated
    READ ENTITIES OF zdd_r_customer_travel_664 IN LOCAL MODE
    ENTITY zdd_r_customer_travel_664
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_CustomerTravel)
    FAILED failed.

* Identify current operation to be authorized
    lv_update_requested = COND #( WHEN requested_authorizations-%update = if_abap_behv=>mk-on OR
                                    requested_authorizations-%update = if_abap_behv=>mk-on
                                  THEN abap_true
                                  ELSE abap_false ).

    lv_delete_requested = COND #( WHEN requested_authorizations-%delete = if_abap_behv=>mk-on
                                  THEN abap_true
                                  ELSE abap_false ).

* Iterate through the root entity records
    DATA(lv_technical_name) = cl_abap_context_info=>get_user_technical_name( ).

    LOOP AT lt_CustomerTravel INTO DATA(ls_CustomerTravel).
      IF lv_update_requested EQ abap_true.
        IF lv_technical_name EQ 'CB9980008560' AND ls_CustomerTravel-CurrencyCode EQ 'USD'.
          lv_update_granted = abap_true.
        ELSE.
          lv_update_granted = abap_false.
        ENDIF.
      ENDIF.

      IF lv_delete_requested EQ abap_true.
        IF lv_technical_name EQ 'CB9980008560' AND ls_CustomerTravel-CurrencyCode EQ 'USD'.
          lv_delete_granted = abap_true.
        ELSE.
          lv_delete_granted = abap_false.
        ENDIF.
      ENDIF.

* Set authorizations to the specified records
      APPEND VALUE #( LET upd_auth = COND #( WHEN lv_update_granted EQ abap_true
                                             THEN if_abap_behv=>auth-allowed
                                             ELSE if_abap_behv=>auth-unauthorized )
                          del_auth = COND #( WHEN lv_delete_granted EQ abap_true
                                              THEN if_abap_behv=>auth-allowed
                                              ELSE if_abap_behv=>auth-unauthorized )
                                              IN
                                              %tky = ls_CustomerTravel-%tky
                                              %update = upd_auth
                                              %action-Edit = upd_auth
                                              %delete = del_auth ) TO result.
    ENDLOOP.

  ENDMETHOD.

  METHOD get_global_authorizations.

    DATA(lv_technical_name) = cl_abap_context_info=>get_user_technical_name( ).

* Set global authorization for the create operation
    IF requested_authorizations-%create EQ if_abap_behv=>mk-on.
      IF lv_technical_name EQ 'CB9980008560' .
        result-%create = if_abap_behv=>auth-allowed.
      ELSE.
        result-%create = if_abap_behv=>auth-unauthorized.
      ENDIF.
    ENDIF.

* Set global authorization for the update operation

    IF requested_authorizations-%update EQ if_abap_behv=>mk-on OR
        requested_authorizations-%action-Edit EQ if_abap_behv=>mk-on.
      IF lv_technical_name EQ 'CB9980008560' .
        result-%update = if_abap_behv=>auth-allowed.
        result-%action-Edit = if_abap_behv=>auth-allowed.
      ELSE.
        result-%update = if_abap_behv=>auth-unauthorized.
        result-%action-Edit = if_abap_behv=>auth-unauthorized.
      ENDIF.
    ENDIF.

* Set global authorization for the delete operation
    IF requested_authorizations-%delete EQ if_abap_behv=>mk-on.
      IF lv_technical_name EQ 'CB9980008560' .
        result-%delete = if_abap_behv=>auth-allowed.
      ELSE.
        result-%delete = if_abap_behv=>auth-unauthorized.
      ENDIF.
    ENDIF.


  ENDMETHOD.

  METHOD acceptClients.

    DATA: lt_updated_root_entity TYPE TABLE FOR UPDATE zdd_r_customer_travel_664,
          lv_discount            TYPE /DMO/BT_DiscountPercentage,
          lv_disc_percent        TYPE f.

* Get parameter discount percent

    READ ENTITIES OF zdd_r_customer_travel_664 IN LOCAL MODE
    ENTITY zdd_r_customer_travel_664
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_root_entity)
    FAILED failed.

* Get parameter discount percent

    LOOP AT lt_root_entity ASSIGNING FIELD-SYMBOL(<ls_root_entity>).
      lv_discount = keys[ KEY id %tky = <ls_root_entity>-%tky ]-%param-travel_discount.
      lv_disc_percent = lv_discount / 100.
      <ls_root_entity>-Price = <ls_root_entity>-Price * ( 1 - lv_disc_percent ).
      <ls_root_entity>-OverallStatus = customer_travel_status-accepted.

      APPEND VALUE #( %tky = <ls_root_entity>-%tky
                Price = <ls_root_entity>-Price
                OverallStatus = <ls_root_entity>-OverallStatus ) TO lt_updated_root_entity.
    ENDLOOP.

    UNASSIGN <ls_root_entity>.

* Modify status in Root Entity
    MODIFY ENTITIES OF zdd_r_customer_travel_664 IN LOCAL MODE
    ENTITY zdd_r_customer_travel_664
    UPDATE
    FIELDS ( Price OverallStatus )
    WITH lt_updated_root_entity.
    FREE lt_root_entity. " Free entries in lt_root_entity

* Read root entity entries updated
    READ ENTITIES OF zdd_r_customer_travel_664 IN LOCAL MODE
    ENTITY zdd_r_customer_travel_664
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT lt_root_entity
    FAILED failed.

*Update User Interface
    result = VALUE #( FOR ls_Customer_Travel IN lt_root_entity
                        ( %tky = ls_Customer_Travel-%tky
                          %param = ls_Customer_Travel ) ).
  ENDMETHOD.

  METHOD rejectClients.

* Modify status in Root Entity
    MODIFY ENTITIES OF zdd_r_customer_travel_664 IN LOCAL MODE
      ENTITY zdd_r_customer_travel_664
      UPDATE FIELDS ( OverallStatus )
      WITH VALUE #( FOR ls_key IN keys
                      ( %tky = ls_key-%tky
                        OverallStatus = customer_travel_status-rejected ) ).

* Read root entity entries updated
    READ ENTITIES OF zdd_r_customer_travel_664 IN LOCAL MODE
    ENTITY zdd_r_customer_travel_664
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_Customer_Travel)
    FAILED failed.

* Update User Interface
    result = VALUE #( FOR ls_Customer_Travel IN lt_Customer_Travel
                        ( %tky = ls_Customer_Travel-%tky
                          %param = ls_Customer_Travel ) ).
  ENDMETHOD.

  METHOD setDescription.
  ENDMETHOD.

  METHOD validateCustomer.
  ENDMETHOD.

ENDCLASS.
