const cds = require('@sap/cds');
const { UPDATE } = require('@sap/cds/lib/ql/cds-ql');
const SapCfMailer = require("sap-cf-mailer").default;
const { executeHttpRequest } = require('@sap-cloud-sdk/http-client');
const { Deliveries } = cds.entities("shipmentService");
require('dotenv').config();


module.exports = cds.service.impl(async function () {
    const { Deliveries } = this.entities

    this.before('SAVE', 'Deliveries', req => {
        const { pickUpDate, estDeliveryDate } = req.data
        if (pickUpDate && estDeliveryDate && pickUpDate > estDeliveryDate) {
            req.error(400, 'Estimated Delivery Date cannot be before Pick Up Date')
        }
    })

    // this.after('READ', 'Deliveries', each => {
    //     if (each.remainingLegs === 0) {
    //         each.shipmentStatus = 'Delivered'
    //     }
    // })

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
                return req.error(400, "Invalid shipment Number")
            }

            await tx.run(UPDATE(Deliveries).set({ shipmentStatus: shipmentStatus }).where({ ID: shipmentDetails.ID }))

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
                { destinationName: process.env.API_DEST },
                { method: 'post', url: process.env.BILLING_DOC_CREATE_API_URL, data: data },
                { fetchCsrfToken: true });

            if (retData.status == 200) {
                await tx.run(UPDATE(Deliveries).set({ billingDocument: retData.data.value[0].BillingDocument }).where({ ID: ID }))

                return req.notify(200, `Billing Document ${retData.data.value[0].BillingDocument} created successfully`)
            }

        } catch (error) {
            return req.error(400, error.response?.data?.error?.message)
        }
    })
})