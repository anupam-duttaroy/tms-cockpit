sap.ui.define([
    "sap/ui/test/opaQunit",
    "./pages/JourneyRunner"
], function (opaTest, runner) {
    "use strict";

    function journey() {
        QUnit.module("First journey");

        opaTest("Start application", function (Given, When, Then) {
            Given.iStartMyApp();

            Then.onTheDeliveriesList.iSeeThisPage();
            Then.onTheDeliveriesList.onFilterBar().iCheckFilterField("Carrier");
            Then.onTheDeliveriesList.onFilterBar().iCheckFilterField("Source");
            Then.onTheDeliveriesList.onFilterBar().iCheckFilterField("Delivery");
            Then.onTheDeliveriesList.onFilterBar().iCheckFilterField("Shipment Number");
            Then.onTheDeliveriesList.onFilterBar().iCheckFilterField("Plant");
            Then.onTheDeliveriesList.onFilterBar().iCheckFilterField("Shipment Status");
            Then.onTheDeliveriesList.onFilterBar().iCheckFilterField("Planned Pick Up Date");
            Then.onTheDeliveriesList.onFilterBar().iCheckFilterField("Estimated Delivery Date");
            Then.onTheDeliveriesList.onTable().iCheckColumns(11, {"deliveryID":{"header":"Delivery"},"billingDocument":{"header":"Commerical Invoice"},"customer":{"header":"Customer"},"plnPickUpDate":{"header":"Planned Pick Up Date"},"shipmentNumber":{"header":"Shipment Number"},"shipmentStatus":{"header":"Shipment Status"},"carrier":{"header":"Carrier"},"plnDeliveryDate":{"header":"Planned Delivery Date"},"estDeliveryDate":{"header":"Estimated Delivery Date"},"destination":{"header":"Destination"},"pickUpDate":{"header":"Actual Pick Up Date"}});

        });


        opaTest("Navigate to ObjectPage", function (Given, When, Then) {
            // Note: this test will fail if the ListReport page doesn't show any data
            
            When.onTheDeliveriesList.onFilterBar().iExecuteSearch();
            
            Then.onTheDeliveriesList.onTable().iCheckRows();

            When.onTheDeliveriesList.onTable().iPressRow(0);
            Then.onTheDeliveriesObjectPage.iSeeThisPage();

        });

        opaTest("Teardown", function (Given, When, Then) { 
            // Cleanup
            Given.iTearDownMyApp();
        });
    }

    runner.run([journey]);
});