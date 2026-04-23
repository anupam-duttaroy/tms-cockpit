sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"tmscockpitfe/test/integration/pages/DeliveriesList",
	"tmscockpitfe/test/integration/pages/DeliveriesObjectPage",
	"tmscockpitfe/test/integration/pages/Deliveries_attachmentsObjectPage"
], function (JourneyRunner, DeliveriesList, DeliveriesObjectPage, Deliveries_attachmentsObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('tmscockpitfe') + '/test/flp.html#app-preview',
        pages: {
			onTheDeliveriesList: DeliveriesList,
			onTheDeliveriesObjectPage: DeliveriesObjectPage,
			onTheDeliveries_attachmentsObjectPage: Deliveries_attachmentsObjectPage
        },
        async: true
    });

    return runner;
});

