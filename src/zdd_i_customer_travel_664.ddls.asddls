@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS - Interface Entity for RAP'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZDD_I_CUSTOMER_TRAVEL_664
  provider contract transactional_interface
  as projection on ZDD_R_CUSTOMER_TRAVEL_664
{
  key CustomerUuid,
      CustomerId,
      Description,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      LastChangedAt,
      /* Associations */
      _Customer
}
