namespace com.logistics.shipment;

using {
    cuid,
    managed
} from '@sap/cds/common';
using {Attachments} from '@cap-js/attachments';

entity Deliveries : cuid, managed {
    deliveryID           : String(10)  @title: 'Delivery';
    billingDocument      : String(10)  @title: 'Billing Document';
    source               : String(100) @title: 'Source';
    destination          : String(100) @title: 'Destination';
    plant                : String(4)   @title: 'Plant';
    packedDate           : Date        @title: 'Packed Date';
    customer             : String(100) @title: 'Customer';
    shipmentNumber       : String(20)  @title: 'Shipment Number';
    shipmentStatus       : String(20)  @title: 'Shipment Status';
    pickUpDate           : DateTime    @title: 'Pick Up Date';
    estDeliveryDate      : DateTime    @title: 'Estimated Delivery Date';
    carrier              : String(100) @title: 'Carrier';
    incoterms            : String(3)   @title: 'Incoterms';
    incoterms2           : String(50)  @title: 'Incoterms 2';
    lastLocation         : String(100) @title: 'Last Location';
    lastLocationDateTime : DateTime    @title: 'Last Location Date/Time';
    systemName           : String(50)  @title: 'System Name';
    endCustomer          : String(100) @title: 'End Customer';
    legType              : String(20)  @title: 'Leg Type';
    remainingLegs        : Integer     @title: 'Remaining Legs';
    attachments          : Composition of many Attachments;
}
