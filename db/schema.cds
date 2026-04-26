namespace com.logistics.shipment;

using {
    cuid,
    managed
} from '@sap/cds/common';
using {Attachments} from '@cap-js/attachments';

entity Deliveries : cuid, managed {
    deliveryID                   : String(10)  @title: 'Delivery';
    billingDocument              : String(10)  @title: 'Commerical Invoice';
    source                       : String(100) @title: 'Source Location';
    destination                  : String(100) @title: 'Destination';
    plant                        : String(4)   @title: 'Plant';
    packedDate                   : Date        @title: 'Packed Date';
    customer                     : String(100) @title: 'Customer';
    shipmentNumber               : String(20)  @title: 'Shipment Number';
    shipmentStatus               : String(20)  @title: 'Shipment Status';
    plnPickUpDate                : DateTime    @title: 'Planned Pick Up Date';
    pickUpDate                   : DateTime    @title: 'Actual Pick Up Date';
    plnDeliveryDate              : DateTime    @title: 'Planned Delivery Date';
    estDeliveryDate              : DateTime    @title: 'Estimated Delivery Date';
    carrier                      : String(100) @title: 'Carrier';
    incoterms                    : String(3)   @title: 'Incoterms';
    incoterms2                   : String(50)  @title: 'Incoterms 2';
    lastLocation                 : String(100) @title: 'Last Location';
    lastLocationDateTime         : DateTime    @title: 'Last Location Date/Time';
    systemName                   : String(50)  @title: 'System Name';
    endCustomer                  : String(100) @title: 'End Customer';
    legType                      : String(20)  @title: 'Leg Type';
    remainingLegs                : Integer     @title: 'Remaining Legs';
    whPickingStatus              : String(10)  @title: 'Warehouse Picking Status';
    pgiStatus                    : String(10)  @title: 'PGI Status';
    whPickingDate                : Date        @title: 'Warehouse Picking Date';
    pgiDate                      : Date        @title: 'PGI Date';
    shipmentCreationDate         : Date        @title: 'Shipment Creation Date';
    actDeliveryDate              : Date        @title: 'Actual Delivery Date';
    onTimeDeliveryStatus         : Integer     @title: 'On-Time Delivery';
    trackingNumber               : String(35)  @title: 'Tracking Number';
    plnPickUpMonth               : Date        @title: 'Planned Pick Up Month';
    estDeliveryMonth             : Date        @title: 'Estimated Delivery Month';
    virtual criticality          : Integer;
    virtual enableCreateBilling  : Boolean;
    virtual enableCreateShipping : Boolean;
    items                        : Composition of many Items
                                       on items.parent = $self;
    attachments                  : Composition of many Attachments;
}

entity Items : cuid, managed {
    parent             : Association to Deliveries;
    product            : String(50)     @title: 'Product';
    quantity           : Decimal(13, 3) @title: 'Quantity';
    serialNumber       : String(30)     @title: 'Serial Number';
    grossWeight        : Decimal(15, 3) @title: 'Gross Weight';
    netWeight          : Decimal(15, 3) @title: 'Net Weight';
    sourceDocument     : String(10)     @title: 'Source Document';
    sourceDocumentItem : String(6)      @title: 'Source Item';
    sourceDocumentType : String(4)      @title: 'Doc Type';
    salesOrder         : String(10)     @title: 'Sales Order';
    salesOrderItem     : String(6)      @title: 'SO Item';
}

view CarrierShipmentCounts as
    select from Deliveries {
        key carrier                     : String(100) @title: 'Carrier',
            count( * ) as shipmentCount : Integer
    }
    where
        carrier is not null
    group by
        carrier;

view SourceShipmentCounts as
    select from Deliveries {
        key source                      : String(100) @title: 'Source Location',
            count( * ) as shipmentCount : Integer
    }
    group by
        source;
