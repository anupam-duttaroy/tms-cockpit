using ShipmentService as service from '../../srv/tms-service';

annotate service.CarrierShipmentCounts with @(
    Aggregation.ApplySupported                    : {
        Transformations       : [
            'aggregate',
            'groupby',
            'filter',
            'identity'
        ],
        GroupableProperties   : [carrier],
        AggregatableProperties: [{
            $Type   : 'Aggregation.AggregatablePropertyType',
            Property: shipmentCount,
        }]
    },
    Analytics.AggregatedProperty #carrierShipCount: {
        $Type               : 'Analytics.AggregatedPropertyType',
        AggregatableProperty: shipmentCount,
        AggregationMethod   : 'sum',
        Name                : 'carrierShipCount',
        ![@Common.Label]    : 'Shipments'
    },
    UI.Chart #vfChartCarrierShipCount             : {
        $Type              : 'UI.ChartDefinitionType',
        ChartType          : #Bar,
        Title              : 'Carrier Shipment Count',
        Dimensions         : [carrier],
        DimensionAttributes: [{
            $Type    : 'UI.ChartDimensionAttributeType',
            Dimension: carrier,
            Role     : #Category
        }],
        DynamicMeasures    : ['@Analytics.AggregatedProperty#carrierShipCount'],
        MeasureAttributes  : [{
            $Type         : 'UI.ChartMeasureAttributeType',
            DynamicMeasure: '@Analytics.AggregatedProperty#carrierShipCount',
            Role          : #Axis1,
            DataPoint     : '@UI.DataPoint#CarrierDP'
        }]
    },
    UI.PresentationVariant #pvqCarrierShip        : {
        $Type         : 'UI.PresentationVariantType',
        Visualizations: ['@UI.Chart#vfChartCarrierShipCount']
    },

    UI.DataPoint #CarrierDP                       : {
        Value       : count,
        Criticality : criticality,
        Description : 'count Score',
        MinimumValue: 0,
        MaximumValue: 100
    }

);

annotate service.SourceShipmentCounts with @(
    Aggregation.ApplySupported                   : {
        Transformations       : [
            'aggregate',
            'groupby',
            'filter',
            'identity'
        ],
        GroupableProperties   : [source],
        AggregatableProperties: [{
            $Type   : 'Aggregation.AggregatablePropertyType',
            Property: shipmentCount,
        }]
    },
    Analytics.AggregatedProperty #sourceShipCount: {
        $Type               : 'Analytics.AggregatedPropertyType',
        AggregatableProperty: shipmentCount,
        AggregationMethod   : 'sum',
        Name                : 'sourceShipCount',
        ![@Common.Label]    : 'Shipments'
    },
    UI.Chart #vfChartSourceShipCount             : {
        $Type              : 'UI.ChartDefinitionType',
        ChartType          : #Bar,
        Title              : 'Source Shipment Count',
        Dimensions         : [source],
        DimensionAttributes: [{
            $Type    : 'UI.ChartDimensionAttributeType',
            Dimension: source,
            Role     : #Category
        }],
        DynamicMeasures    : ['@Analytics.AggregatedProperty#sourceShipCount'],
        MeasureAttributes  : [{
            $Type         : 'UI.ChartMeasureAttributeType',
            DynamicMeasure: '@Analytics.AggregatedProperty#sourceShipCount',
            Role          : #Axis1,
            DataPoint     : '@UI.DataPoint#SourceDP'
        }]
    },
    UI.PresentationVariant #pvqSourceShip        : {
        $Type         : 'UI.PresentationVariantType',
        Visualizations: ['@UI.Chart#vfChartSourceShipCount']
    },
    UI.DataPoint #SourceDP                       : {
        Value       : count,
        Criticality : criticality,
        Description : 'count Score',
        MinimumValue: 0,
        MaximumValue: 100
    }
);


annotate service.Deliveries with @(
    Analytics.AggregatedProperty #shipmentCountNew : {
        $Type               : 'Analytics.AggregatedPropertyType',
        Name                : 'shipmentCountNew',
        AggregationMethod   : 'count',
        AggregatableProperty: shipmentNumber,
        @Common.Label       : 'Shipments',
    },
    Analytics.AggregatedProperty #deliveryCountNew : {
        $Type               : 'Analytics.AggregatedPropertyType',
        Name                : 'deliveryCountNew',
        AggregationMethod   : 'count',
        AggregatableProperty: deliveryID,
        @Common.Label       : 'Shipments',
    },
    UI.Chart #base                                 : {
        $Type              : 'UI.ChartDefinitionType',
        Description        : 'Shipment Chart',
        Title              : 'Shipments Status',
        ChartType          : #Column,
        Dimensions         : [
            plant,
            shipmentStatus
        ],
        DimensionAttributes: [
            {
                $Type    : 'UI.ChartDimensionAttributeType',
                Dimension: plant,
                Role     : #Category,
            },
            {
                $Type    : 'UI.ChartDimensionAttributeType',
                Dimension: shipmentStatus,
                Role     : #Series,
            },
        ],
        DynamicMeasures    : ['@Analytics.AggregatedProperty#deliveryCountNew',
        ],
        MeasureAttributes  : [
            {
                $Type         : 'UI.ChartMeasureAttributeType',
                DynamicMeasure: '@Analytics.AggregatedProperty#deliveryCountNew',
                Role          : #Axis1,
            },
            {
                $Type         : 'UI.ChartMeasureAttributeType',
                DynamicMeasure: '',
                Role          : #Axis1,
            },
        ],
    },
    UI.PresentationVariant                         : {
        $Type         : 'UI.PresentationVariantType',
        Visualizations: [
            '@UI.LineItem',
            '@UI.Chart#base',
        ],
    },

    UI.Chart #vfChartPlannedPickedMonth            : {
        $Type              : 'UI.ChartDefinitionType',
        ChartType          : #Line,
        Title              : 'Planned Picked Date',
        Description        : 'Planned Picked Date',
        Dimensions         : [plnPickUpMonth],
        DimensionAttributes: [{
            $Type    : 'UI.ChartDimensionAttributeType',
            Dimension: plnPickUpMonth,
            Role     : #Category,
        }, ],
        DynamicMeasures    : ['@Analytics.AggregatedProperty#deliveryCountNew'],
        MeasureAttributes  : [{
            $Type         : 'UI.ChartMeasureAttributeType',
            DynamicMeasure: '@Analytics.AggregatedProperty#deliveryCountNew',
            Role          : #Axis1,

        }],
    },

    UI.PresentationVariant #pvqLineChart           : {
        $Type         : 'UI.PresentationVariantType',
        Visualizations: ['@UI.Chart#vfChartPlannedPickedMonth'],
    },
    UI.Chart #vfChartestDeliveryMonth              : {
        $Type              : 'UI.ChartDefinitionType',
        ChartType          : #Line,
        Title              : 'Estimated Delivery',
        Description        : 'Estimated Delivery',
        Dimensions         : [estDeliveryMonth],
        DimensionAttributes: [{
            $Type    : 'UI.ChartDimensionAttributeType',
            Dimension: estDeliveryMonth,
            Role     : #Category,
        }, ],
        DynamicMeasures    : ['@Analytics.AggregatedProperty#deliveryCountNew'],
        MeasureAttributes  : [{
            $Type         : 'UI.ChartMeasureAttributeType',
            DynamicMeasure: '@Analytics.AggregatedProperty#deliveryCountNew',
            Role          : #Axis1,

        }],
    },

    UI.PresentationVariant #pvqLineChartESTDelivery: {
        $Type         : 'UI.PresentationVariantType',
        Visualizations: ['@UI.Chart#vfChartestDeliveryMonth'],
    },
);

annotate service.Deliveries with {
    carrier          @Common.ValueList #vlCarrier         : {
        $Type                       : 'Common.ValueListType',
        CollectionPath              : 'CarrierShipmentCounts',
        PresentationVariantQualifier: 'pvqCarrierShip',
        Parameters                  : [{
            $Type            : 'Common.ValueListParameterInOut',
            LocalDataProperty: carrier,
            ValueListProperty: 'carrier',
        }, ],
    };
    source           @Common.ValueList #vlSource          : {
        $Type                       : 'Common.ValueListType',
        CollectionPath              : 'SourceShipmentCounts',
        PresentationVariantQualifier: 'pvqSourceShip',
        Parameters                  : [{
            $Type            : 'Common.ValueListParameterInOut',
            LocalDataProperty: source,
            ValueListProperty: 'source',
        }, ],
    };
    plnPickUpMonth   @Common.ValueList #vlplnPickUpMonth  : {
        $Type                       : 'Common.ValueListType',
        CollectionPath              : 'Deliveries',
        PresentationVariantQualifier: 'pvqLineChart',
        Parameters                  : [{
            $Type            : 'Common.ValueListParameterInOut',
            LocalDataProperty: plnPickUpMonth,
            ValueListProperty: 'plnPickUpMonth',
        }, ],
    };
    estDeliveryMonth @Common.ValueList #vlestDeliveryMonth: {
        $Type                       : 'Common.ValueListType',
        CollectionPath              : 'Deliveries',
        PresentationVariantQualifier: 'pvqLineChartESTDelivery',
        Parameters                  : [{
            $Type            : 'Common.ValueListParameterInOut',
            LocalDataProperty: estDeliveryMonth,
            ValueListProperty: 'estDeliveryMonth',
        }, ],
    }
};
