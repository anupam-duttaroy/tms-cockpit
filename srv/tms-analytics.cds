// using {com.logistics.shipment as my} from '../db/schema';

// service ShipmentAnalyticsService {

//     //entity DeliveriesAnalytics as projection on my.Deliveries;

//     @readonly
//     entity DeliveriesAnalytics as
//         select from my.Deliveries {
//             ID,
//             deliveryID,
//             shipmentNumber,
//             shipmentStatus,
//             customer,
//             // Reach into the items composition to get the weight
//             items.grossWeight as itemGrossWeight : Decimal(15, 3)
//         };

// }

// annotate ShipmentAnalyticsService.DeliveriesAnalytics with @(

//     Aggregation.ApplySupported                    : {
//         Transformations       : [
//             'aggregate',
//             'topcount',
//             'bottomcount',
//             'identity',
//             'concat',
//             'groupby',
//             'filter',
//             'expand',
//             'search'
//         ],

//         GroupableProperties   : [
//             ID,
//             deliveryID,
//             billingDocument,
//             shipmentNumber,
//             shipmentStatus
//         ],

//         AggregatableProperties: [
//             {
//                 Type    : 'Aggregation.AggregatablePropertyType',
//                 Property: itemGrossWeight
//             },
//             {
//                 Type    : 'Aggregation.AggregatablePropertyType',
//                 Property: shipmentNumber
//             }
//         ]
//     },

//     Analytics.AggregatedProperty #totalGrossWeight: {
//         $Type               : 'Analytics.AggregatedPropertyType',
//         AggregatableProperty: itemGrossWeight,
//         AggregationMethod   : 'sum',
//         Name                : 'itemGrossWeight',
//         ![@Common.Label]    : 'Total Gross Weight'
//     },

//     Analytics.AggregatedProperty #countOfShipments: {
//         $Type               : 'Analytics.AggregatedPropertyType',
//         AggregatableProperty: shipmentNumber,
//         AggregationMethod   : 'count',
//         Name                : 'countOfShipments',
//         ![@Common.Label]    : 'Number of Shipments'
//     }

// );

// annotate ShipmentAnalyticsService.DeliveriesAnalytics with @(
//     UI.Chart              : {
//         $Type              : 'UI.ChartDefinitionType',
//         Title              : 'Gross Weight',
//         ChartType          : #Column,
//         Dimensions         : [
//             deliveryID,
//             shipmentNumber
//         ],
//         DimensionAttributes: [
//             {
//                 $Type    : 'UI.ChartDimensionAttributeType',
//                 Dimension: deliveryID,
//                 Role     : #Category
//             },
//             {
//                 $Type    : 'UI.ChartDimensionAttributeType',
//                 Dimension: shipmentNumber,
//                 Role     : #Category2
//             }
//         ],
//         DynamicMeasures    : [ ![@Analytics.AggregatedProperty#totalGrossWeight] ],
//         MeasureAttributes  : [{
//             $Type         : 'UI.ChartMeasureAttributeType',
//             DynamicMeasure: ![@Analytics.AggregatedProperty#totalGrossWeight],
//             Role          : #Axis1
//         }]
//     },
//     UI.PresentationVariant: {
//         $Type         : 'UI.PresentationVariantType',
//         Visualizations: [
//             '@UI.Chart',
//             '@UI.Chart #StatusDonut'
//         ],
//     }
// );


// annotate ShipmentAnalyticsService.DeliveriesAnalytics with @(
//     UI.Chart #StatusDonut                : {
//         $Type              : 'UI.ChartDefinitionType',
//         Title              : 'Shipment Status Distribution',
//         ChartType          : #Donut,
//         Dimensions         : [shipmentStatus],
//         DimensionAttributes: [{
//             $Type    : 'UI.ChartDimensionAttributeType',
//             Dimension: shipmentStatus,
//             Role     : #Category
//         }],
//         DynamicMeasures    : [ ![@Analytics.AggregatedProperty#countOfShipments] ],
//         MeasureAttributes  : [{
//             $Type         : 'UI.ChartMeasureAttributeType',
//             DynamicMeasure: ![@Analytics.AggregatedProperty#countOfShipments],
//             Role          : #Axis1
//         }]
//     },
//     UI.PresentationVariant #StatusDonutPV: {
//         $Type         : 'UI.PresentationVariantType',
//         Visualizations: ['@UI.Chart#StatusDonut']
//     }
// );

// annotate ShipmentAnalyticsService.DeliveriesAnalytics with @(
//     UI.Chart #DeliveryID                  : {
//         $Type          : 'UI.ChartDefinitionType',
//         ChartType      : #Bar,
//         Dimensions     : [deliveryID],
//         DynamicMeasures: [ ![@Analytics.AggregatedProperty#totalGrossWeight] ]
//     },
//     UI.PresentationVariant #prevDeliveryID: {
//         $Type         : 'UI.PresentationVariantType',
//         Visualizations: ['@UI.Chart#DeliveryID',
//         ],
//     }
// ) {
//     deliveryID     @Common.ValueList #vlDeliveryID: {
//         $Type                       : 'Common.ValueListType',
//         CollectionPath              : 'DeliveriesAnalytics',
//         Parameters                  : [{
//             $Type            : 'Common.ValueListParameterInOut',
//             ValueListProperty: 'deliveryID',
//             LocalDataProperty: deliveryID
//         }],
//         PresentationVariantQualifier: 'prevDeliveryID'
//     };
//     shipmentStatus @Common.ValueList #vlStatus    : {
//         $Type                       : 'Common.ValueListType',
//         CollectionPath              : 'DeliveriesAnalytics',
//         Parameters                  : [{
//             $Type            : 'Common.ValueListParameterInOut',
//             ValueListProperty: 'shipmentStatus',
//             LocalDataProperty: shipmentStatus
//         }],
//         PresentationVariantQualifier: 'StatusDonutPV'
//     };
// }

// annotate ShipmentAnalyticsService.DeliveriesAnalytics with @(UI: {
//     SelectionFields: [
//         deliveryID,
//         shipmentNumber,
//         shipmentStatus
//     ],
//     LineItem       : [
//         {
//             $Type: 'UI.DataField',
//             Value: ID,
//         },
//         {
//             $Type: 'UI.DataField',
//             Value: deliveryID,
//         },
//         {
//             $Type: 'UI.DataField',
//             Value: shipmentNumber,
//         },
//         {
//             $Type: 'UI.DataField',
//             Value: shipmentStatus,
//         },
//         {
//             $Type: 'UI.DataField',
//             Value: itemGrossWeight,
//         },
//     ],
// });
