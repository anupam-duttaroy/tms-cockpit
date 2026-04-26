using {com.logistics.shipment as my} from '../db/schema';

service ShipmentService {
    @odata.draft.enabled
    @cds.redirection.target
    entity Deliveries as projection on my.Deliveries
        actions {
            // Action to create a shipment for multiple selected deliveries
            @(
                Common.SideEffects     : {TargetProperties: [
                    'in/shipmentStatus',
                    'in/shipmentNumber'
                ]},
                Core.OperationAvailable: in.enableCreateShipping
            )
            action createShipment() returns String;

            @(
                Common.SideEffects     : {TargetProperties: ['in/billingDocument']},
                //Core.OperationAvailable: {$edmJson: {$Eq: [ {$Path: 'in/enableCreateBilling'}, true ]}},
                Core.OperationAvailable: in.enableCreateBilling

            )
            action createBilling()  returns String;
        };

    action updateShipmentStatus(shipmentNumber: String,
                                shipmentStatus: String,
                                fileName: String,
                                fileContent: String) returns String;

    entity Items      as projection on my.Items;
    view CarrierShipmentCounts as select from my.CarrierShipmentCounts;
    view SourceShipmentCounts as select from my.SourceShipmentCounts;
//view DeliveryPickupMonthly as select from my.DeliveryPickupMonthly;
}

annotate ShipmentService.Items with @(UI.LineItem: [
    {Value: product},
    {Value: quantity},
    {Value: serialNumber},
    {Value: grossWeight},
    {Value: salesOrder}
]);

annotate ShipmentService.Deliveries with @(
    // Data Point for Shipment Status
    UI.DataPoint #Status       : {
        Value      : shipmentStatus,
        Title      : 'Shipment Status',
        Criticality: onTimeDeliveryStatus
    },
    // Data Point for Leg Type
    UI.DataPoint #LegType      : {
        Value: legType,
        Title: 'Leg Type'
    },
    // Data Point for Leg Type
    UI.DataPoint #SourceLoc    : {
        Value: source,
        Title: 'Source'
    },
    // Data Point for Leg Type
    UI.DataPoint #DestLoc      : {
        Value: destination,
        Title: 'Destination'
    },
    // Data Point for Remaining Legs
    UI.DataPoint #RemainingLegs: {
        Value: remainingLegs,
        Title: 'Legs Remaining'
    },
    // Data Point for Last Update (using the managed 'modifiedAt' field)
    UI.DataPoint #LastLoc      : {
        Value: lastLocation,
        Title: 'Last Location'
    },
    // Data Point for Last Update (using the managed 'modifiedAt' field)
    UI.DataPoint #LastUpdate   : {
        Value: lastLocationDateTime,
        Title: 'Last Location Update'
    },
    UI.HeaderFacets            : [
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'StatusHeader',
            Target: '@UI.DataPoint#Status'
        },
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'SourceHeader',
            Target: '@UI.DataPoint#SourceLoc'
        },
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'DestHeader',
            Target: '@UI.DataPoint#DestLoc'
        },
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'LegTypeHeader',
            Target: '@UI.DataPoint#LegType'
        },
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'LegsHeader',
            Target: '@UI.DataPoint#RemainingLegs'
        },
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'LocHeader',
            Target: '@UI.DataPoint#LastLoc'
        },
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'UpdateHeader',
            Target: '@UI.DataPoint#LastUpdate'
        }
    ],

    UI.LineItem                : {
        @UI.Criticality: criticality,
        // Add the Action Button to the Table Toolbar
        $value         : [
            {
                $Type             : 'UI.DataFieldForAction',
                Label             : 'Create Shipment',
                Action            : 'ShipmentService.createShipment',
                InvocationGrouping: #ChangeSet // Ensures all IDs are sent in one request
            },
            {
                $Type             : 'UI.DataFieldForAction',
                Label             : 'Create Commercial Invoice',
                Action            : 'ShipmentService.createBilling',
                InvocationGrouping: #ChangeSet,
            // Ensures all IDs are sent in one request
            },
            {
                $Type: 'UI.DataField',
                Value: deliveryID
            },
            {
                $Type: 'UI.DataField',
                Value: billingDocument
            },
            // {
            //     $Type: 'UI.DataField',
            //     Value: onTimeDeliveryStatus,
            //     Criticality: onTimeDeliveryStatus,
            //     CriticalityRepresentation: #WithIcon
            // },
            {
                $Type: 'UI.DataField',
                Value: customer
            },
            {
                $Type: 'UI.DataField',
                Value: plnPickUpDate
            },
            {
                $Type: 'UI.DataField',
                Value: shipmentNumber
            },
            {
                $Type                    : 'UI.DataField',
                Value                    : shipmentStatus,
                Criticality              : onTimeDeliveryStatus,
                CriticalityRepresentation: #WithoutIcon
            },
            {
                $Type: 'UI.DataField',
                Value: carrier
            },
            {
                $Type: 'UI.DataField',
                Value: plnDeliveryDate
            },
            {
                $Type: 'UI.DataField',
                Value: estDeliveryDate
            },
            {
                $Type: 'UI.DataField',
                Value: destination
            },
            {
                $Type: 'UI.DataField',
                Value: pickUpDate
            }
        ]
    },
    UI.SelectionFields         : [
        carrier,
        source,
        deliveryID,
        shipmentNumber,
        plant,
        shipmentStatus,
        plnPickUpDate,
        estDeliveryDate,
        plnPickUpMonth
    ],
    UI.HeaderInfo              : {
        TypeName      : 'Delivery',
        TypeNamePlural: 'Deliveries',
        Title         : {Value: deliveryID},
        Description   : {Value: shipmentNumber}
    },
    UI.Facets                  : [
        {
            $Type : 'UI.CollectionFacet',
            Label : 'Shipment Details',
            ID    : 'ShipmentDetails',
            Facets: [
                {
                    $Type : 'UI.ReferenceFacet',
                    Label : 'General Info',
                    Target: '@UI.FieldGroup#General'
                },
                // { $Type: 'UI.ReferenceFacet', Label: 'Logistics Info', Target: '@UI.FieldGroup#Logistics' },
                {
                    $Type : 'UI.ReferenceFacet',
                    Label : 'Systems & Terms',
                    Target: '@UI.FieldGroup#Terms'
                },
                {
                    $Type : 'UI.ReferenceFacet',
                    Label : 'Timeline & Dates',
                    ID    : 'DatesSection',
                    Target: '@UI.FieldGroup#DatesGroup'
                }
            ]
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Delivery Items',
            Target: 'items/@UI.LineItem'
        }
    ],
    UI.FieldGroup #General     : {Data: [
        {Value: deliveryID},
        {Value: customer},
        {Value: endCustomer},
        {Value: plant},
        {Value: shipmentStatus},
        {Value: billingDocument}
    ]},
    UI.FieldGroup #Logistics   : {Data: [
        {Value: shipmentNumber},
        {Value: shipmentStatus},
        {Value: trackingNumber},
        {Value: source},
        {Value: destination},
        // { Value: pickUpDate },
        // { Value: estDeliveryDate },
        // { Value: lastLocation },
        // { Value: lastLocationDateTime },
        {Value: whPickingStatus},
        {Value: pgiStatus},
        {Value: legType},
        {Value: remainingLegs}
    ]},
    UI.FieldGroup #Terms       : {Data: [
        {Value: carrier},
        {Value: incoterms},
        {Value: incoterms2},
        {Value: systemName}
    ]},
    UI.FieldGroup #DatesGroup  : {Data: [
        {Value: plnPickUpDate},
        {Value: whPickingDate},
        {Value: pickUpDate},
        {Value: pgiDate},
        {Value: plnDeliveryDate},
        {Value: estDeliveryDate},
        {Value: actDeliveryDate},
        {Value: lastLocationDateTime}
    ]}
);

annotate ShipmentService.Deliveries with @(Capabilities.FilterRestrictions: {FilterExpressionRestrictions: [
    {
        Property          : 'estDeliveryDate',
        AllowedExpressions: 'SingleRange'
    },
    {
        Property          : 'plnDeliveryDate',
        AllowedExpressions: 'SingleRange'
    },
    // {
    //     Property          : 'plnPickUpDate',
    //     AllowedExpressions: 'SingleRange'
    // },
    {
        Property          : 'actDeliveryDate',
        AllowedExpressions: 'SingleRange'
    },
    {
        Property          : 'shipmentCreationDate',
        AllowedExpressions: 'SingleRange'
    }
]});

//Aggregation and analytical annotations
annotate ShipmentService.Deliveries with @(Aggregation.ApplySupported: {
    Transformations       : [
        'aggregate',
        'topcount',
        'bottomcount',
        'identity',
        'concat',
        'groupby',
        'filter',
        'expand',
        'search'
    ],
    GroupableProperties   : [
        carrier,
        source,
        shipmentNumber,
        shipmentStatus,
        deliveryID,
        plnDeliveryDate,
        plnPickUpDate,
        plant,
        plnPickUpMonth,
        estDeliveryDate
    ],
    AggregatableProperties: [
        {Property: shipmentStatus},
        {Property: plnDeliveryDate},
        {Property: deliveryID},
        {Property: shipmentNumber},
    ]
}, )
