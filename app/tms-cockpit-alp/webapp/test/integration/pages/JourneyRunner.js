sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"tmscockpitalp/test/integration/pages/DeliveriesList",
	"tmscockpitalp/test/integration/pages/DeliveriesObjectPage"
], function (JourneyRunner, DeliveriesList, DeliveriesObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('tmscockpitalp') + '/test/flp.html#app-preview',
        pages: {
			onTheDeliveriesList: DeliveriesList,
			onTheDeliveriesObjectPage: DeliveriesObjectPage
        },
        async: true
    });

    return runner;
});

