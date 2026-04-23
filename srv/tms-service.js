const cds = require('@sap/cds')
const SapCfMailer = require("sap-cf-mailer").default;
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

    this.on("updateShipmentStatus", req => {


        try {

            const transporter = new SapCfMailer("DebjaniMail"); // Match your destination

            const result = await transporter.sendMail({

                to: "debjani.jena@innovervglobal.com", //to list separated by comma

                subject: "Test Mail from BTP System",

                html: "Hello from CAP!",

                attachments: []

            });

            return `Email sent successfully`;

        } catch (error) {

            console.error('Error sending email:', error);

            return `Error sending email: ${error.message}`;

        }




    })

})