const cds = require('@sap/cds');
const { UPDATE } = require('@sap/cds/lib/ql/cds-ql');
const SapCfMailer = require("sap-cf-mailer").default;
const { executeHttpRequest } = require('@sap-cloud-sdk/http-client');
const { Deliveries } = cds.entities("shipmentService");
require('dotenv').config();


module.exports = cds.service.impl(async function () {
    const { Deliveries } = this.entities

    // this.before('SAVE', 'Deliveries', req => {
    //     const { pickUpDate, estDeliveryDate } = req.data
    //     if (pickUpDate && estDeliveryDate && pickUpDate > estDeliveryDate) {
    //         req.error(400, 'Estimated Delivery Date cannot be before Pick Up Date')
    //     }
    // });

    this.on('createShipment', 'Deliveries', async req => {

        const tx = cds.transaction(req);
        // req.params contains the IDs of the selected deliveries
        const selectedDeliveries = req.params
        console.log("test", req.params);
        if (!selectedDeliveries || selectedDeliveries.length === 0) {
            return req.error(400, 'Please select at least one delivery.')
        }

        console.log(`Processing shipment for ${selectedDeliveries.length} deliveries.`)

        // Dummy Logic: Update status to 'In Transit' for all selected items
        for (const delivery of selectedDeliveries) {
            var deliveryDetails = await tx.run(
                SELECT.one.from(Deliveries).where({ ID: delivery.ID }),
            );

            let data = { "deliveryID": deliveryDetails.deliveryID, ID: deliveryDetails.ID }

            const retData = await executeHttpRequest(
                { destinationName: 'IS_SHPCRT' },
                { method: 'post', url: '/http/tms/shipment', data: data });

            await UPDATE(Deliveries).set({
                shipmentStatus: 'Shipment Created', shipmentNumber: retData.data.shipmentNumber,
                shipmentCreationDate: new Date().toISOString()
            }).where({ ID: delivery.ID })
        }
        
        return req.notify(200, `Shipment ${retData?.data?.shipmentNumber} created successfully`)
    });

    this.after('READ', 'Deliveries', async (each) => {
        const today = new Date();
        const twoDaysFromNow = new Date();
        twoDaysFromNow.setDate(today.getDate() + 2);

        const IDs = each.map(obj => obj.ID);
        const rows = await SELECT.from(Deliveries).where({ ID: { in: IDs } });

        rows.forEach((row, idx) => {
        
        const plnPickUp = row.plnPickUpDate ? new Date(row.plnPickUpDate) : null;
        const estDelivery = row.estDeliveryDate ? new Date(row.estDeliveryDate) : null;
        const lastUpdate = row.lastLocationDateTime ? new Date(row.lastLocationDateTime) : null;
        if (row.shipmentNumber == 'SHP-964337') {
            console.log(row);
        }

        // if (!each.plnPickUpMonth && each.plnPickUpDate) {
        //     const d = new Date(each.plnPickUpDate);
        //     each.plnPickUpMonth = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-01`;
        // }

        //if (!each.plnPickUpMonth && each.plnPickUpDate) {
        // console.log('plnPickUpMonth:', each.plnPickUpMonth, '| type:', typeof each.plnPickUpMonth);
        // console.log('plnPickUpDate:', each.plnPickUpDate, '| type:', typeof each.plnPickUpDate);

        // const d = new Date(each.plnPickUpDate);
        //  each.plnPickUpMonth = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-01T00:00:00Z`;

        // const newdate = new Date(formattedDate);
        // each.plnPickUpMonth = newdate;


        // console.log('plnPickUpMonth (after):', each.plnPickUpMonth, '| type:', typeof each.plnPickUpMonth);
        //}

        // by default, make the button disabled, 
        // if shipment number is generated but billing document is not generated yet, 
        // then make button enabled
        row.enableCreateBilling = false;
        if (row.shipmentNumber && !row.billingDocument) {
            row.enableCreateBilling = true
        }

        // by default, make the button disabled, 
        // if shipment number is not generated yet, 
        // then make button enabled
        row.enableCreateShipping = false;
        if (!row.shipmentNumber) {
            row.enableCreateShipping = true
        }

        // --- RED LOGIC ---
        const isRed = (plnPickUp < today && !row.pickUpDate) ||
            (estDelivery < today && row.shipmentStatus !== 'Delivered');
        var isAmber = null;
        if (!isRed) {
            // --- AMBER LOGIC ---
            const lastUpdateThreshold = new Date();
            lastUpdateThreshold.setDate(today.getDate() - 2);

            isAmber = ((estDelivery <= twoDaysFromNow && lastUpdate <= lastUpdateThreshold) ||
                (plnPickUp <= twoDaysFromNow && !row.shipmentNumber)) && row.shipmentStatus !== 'Delivered';
        }
        
        if (isRed) {
            row.criticality = 1; // Red
        } else if (isAmber == true) {
            row.criticality = 2; // Amber
        } else {
            row.criticality = 3; // Green
        }

        // if (each.shipmentStatus == 'Delivered'){
        //     console.log(each.actDeliveryDate, each.estDeliveryDate);
        //     if (each.actDeliveryDate > each.estDeliveryDate ) each.onTimeDeliveryStatus = 1
        //     else if (each.actDeliveryDate <= each.estDeliveryDate ) each.onTimeDeliveryStatus = 3
        //     else each.onTimeDeliveryStatus = 2
        // }
        each[idx].criticality = row.criticality;
        });
        console.log(rows);

    });

    // this.before('READ', 'Deliveries', (req) => {
    //     const query = req.query;

    //     // Only proceed if SELECT exists
    //     if (query.SELECT) {
    //         const cols = query.SELECT.columns;

    //         // If no columns specified, it's already SELECT *
    //         if (!cols) return;

    //         // Helper to check if column already exists
    //         const hasColumn = (name) =>
    //             cols.some(c => c.ref && c.ref[0] === name);

    //         // Add fields if missing
    //         if (!hasColumn('plnPickUpDate')) {
    //             cols.push({ ref: ['plnPickUpDate'] });
    //         }

    //         if (!hasColumn('estDeliveryDate')) {
    //             cols.push({ ref: ['estDeliveryDate'] });
    //         }

    //         const grp = query.SELECT.groupBy;
    //         if (!grp) return;
    //         const hasGroupby = (name) =>
    //             cols.some(c => c.ref && c.ref[0] === name);
    //         if (!hasGroupby('plnPickUpDate')) {
    //             cols.push({ ref: ['plnPickUpDate'] });
    //         }

    //         if (!hasGroupby('estDeliveryDate')) {
    //             cols.push({ ref: ['estDeliveryDate'] });
    //         }
    //     }
    // });


    this.on("updateShipmentStatus", async (req) => {


        try {
            const tx = cds.transaction(req);
            const { shipmentNumber, shipmentStatus, fileName, fileContent } = req.data

            var shipmentDetails = await tx.run(
                SELECT.one.from(Deliveries).where({
                    shipmentNumber: shipmentNumber
                }),
            );

            if (!shipmentDetails) {
                return req.error(400, `Invalid shipment Number ${shipmentNumber}`)
            }

            const today = new Date().toISOString().split('.')[0] + 'Z';
            let onTimeDeliveryStatus;
            shipmentDetails.actDeliveryDate = today;
            if (shipmentStatus == 'Delivered') {
                if (shipmentDetails.actDeliveryDate > shipmentDetails.estDeliveryDate) onTimeDeliveryStatus = 1
                else if (shipmentDetails.actDeliveryDate <= shipmentDetails.estDeliveryDate) onTimeDeliveryStatus = 3
                else onTimeDeliveryStatus = 2
            }

            await tx.run(UPDATE(Deliveries).set({
                shipmentStatus: shipmentStatus,
                onTimeDeliveryStatus: onTimeDeliveryStatus
            }).where({ ID: shipmentDetails.ID }))

            let htmlContent = `<div style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
            <p>Hello,</p>
            <p>Delivery <strong>${shipmentNumber}</strong> has been completed. Please find the receipt attached.</p>
            <p>Regards,<br>
            <strong>${shipmentDetails.carrier} Delivery Team</strong></p>
        </div>`
            const transporter = new SapCfMailer(process.env.MAIL_DEST);

            const result = await transporter.sendMail({
                to: process.env.RECEIVER_MAIL,
                subject: `Delivery completed for ${shipmentNumber}`,
                html: htmlContent,
                attachments: [{ filename: fileName, content: fileContent, encoding: "base64" }]
            });

            return req.notify(200, `Status updated for Shipment ${shipmentNumber}`);

        } catch (error) {

            console.error('Error updating status:', error);
            return req.error(400, `Error updating status: ${error.message}`);
        }
    })

    this.on("createBilling", async (req) => {

        try {
            const ID = req.params[0].ID;
            const tx = cds.transaction(req);

            var deliveryDetails = await tx.run(
                SELECT.one.from(Deliveries).where({
                    ID: ID
                }),
            );

            if (!deliveryDetails) {
                return req.error(400, "Invalid Delivery Number")
            }

            const data = {
                _Control: {
                    DefaultBillingDocumentDate: "2017-04-13",
                    DefaultBillingDocumentType: "F8",
                    AutomPostingToAcctgIsDisabled: true,
                    CutOffBillingDocumentDate: "2017-04-13"
                },
                _Reference: [
                    {
                        SDDocument: deliveryDetails.deliveryID,
                        BillingDocumentType: "F8",
                        BillingDocumentDate: "2017-04-13",
                        DestinationCountry: "GB",
                        SalesOrganization: "GB01",
                        SDDocumentCategory: "J"
                    }
                ]
            };

            const retData = await executeHttpRequest(
                { destinationName: process.env.API_DEST || 'S4HC_1' },
                { method: 'post', url: process.env.BILLING_DOC_CREATE_API_URL || '/sap/opu/odata4/sap/api_billingdocument/srvd_a2x/sap/billingdocument/0001/BillingDocument/SAP__self.CreateFromSDDocument', 
                    data: data },
                { fetchCsrfToken: true });

            if (retData.status == 200) {
                await tx.run(UPDATE(Deliveries).set({ billingDocument: retData?.data?.value[0]?.BillingDocument }).where({ ID: ID }))

                return req.notify(200, `Billing Document ${retData?.data?.value[0]?.BillingDocument} created successfully`)
            }

        } catch (error) {
            return req.error(400, error.response?.data?.error?.message)
        }
    })
})