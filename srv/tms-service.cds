using {com.logistics.shipment as my} from '../db/schema';

service ShipmentService {
    @odata.draft.enabled
    entity Deliveries as projection on my.Deliveries;

    action updateShipmentStatus(delivery: String,
                                status: String,
                                fileName: String,
                                fileContent: String) returns String;
}


annotate ShipmentService.Deliveries with @(
    UI.LineItem             : [
        {Value: deliveryID},
        {Value: shipmentNumber},
        {Value: shipmentStatus},
        {Value: carrier},
        {Value: estDeliveryDate},
        {Value: destination}
    ],
    UI.SelectionFields      : [
        deliveryID,
        shipmentNumber,
        plant,
        shipmentStatus
    ],
    UI.HeaderInfo           : {
        TypeName      : 'Delivery',
        TypeNamePlural: 'Deliveries',
        Title         : {Value: deliveryID},
        Description   : {Value: shipmentNumber}
    },
    UI.Facets               : [{
        $Type : 'UI.CollectionFacet',
        Label : 'Shipment Details',
        ID    : 'ShipmentDetails',
        Facets: [
            {
                $Type : 'UI.ReferenceFacet',
                Label : 'General Info',
                Target: '@UI.FieldGroup#General'
            },
            {
                $Type : 'UI.ReferenceFacet',
                Label : 'Logistics Info',
                Target: '@UI.FieldGroup#Logistics'
            },
            {
                $Type : 'UI.ReferenceFacet',
                Label : 'Systems & Terms',
                Target: '@UI.FieldGroup#Terms'
            }
        ]
    }],
    UI.FieldGroup #General  : {Data: [
        {Value: deliveryID},
        {Value: customer},
        {Value: endCustomer},
        {Value: plant},
        {Value: packedDate}
    ]},
    UI.FieldGroup #Logistics: {Data: [
        {Value: shipmentNumber},
        {Value: shipmentStatus},
        {Value: source},
        {Value: destination},
        {Value: pickUpDate},
        {Value: estDeliveryDate},
        {Value: lastLocation},
        {Value: lastLocationDateTime},
        {Value: legType},
        {Value: remainingLegs}
    ]},
    UI.FieldGroup #Terms    : {Data: [
        {Value: carrier},
        {Value: incoterms},
        {Value: incoterms2},
        {Value: systemName}
    ]}
);
