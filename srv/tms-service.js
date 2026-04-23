const cds = require('@sap/cds');
const { UPDATE } = require('@sap/cds/lib/ql/cds-ql');
const SapCfMailer = require("sap-cf-mailer").default;

const { Deliveries } = cds.entities("shipmentService");


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
            const { delivery, status, fileName, fileContent } = req.data

            var deliveryKeyID = await tx.run(
                SELECT.one.from(Deliveries).where({
                    deliveryID: delivery
                }),
            );

            if (!deliveryKeyID) {
                return req.error(400, "Invalid delivery Number")
            }

            await tx.run(UPDATE(Deliveries).set({ shipmentStatus: status }).where({ ID: deliveryKeyID.ID }))
            
            let htmlContent = `<div style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
            <p>Hello,</p>
            <p>Delivery <strong>${delivery}</strong> has been completed. Please find the receipt attached.</p>
            <p>Regards,<br>
            <strong>${deliveryKeyID.carrier} Delivery Team</strong></p>
        </div>`
            const transporter = new SapCfMailer(process.env.MAIL_DEST);

            const result = await transporter.sendMail({
                to: process.env.RECEIVER_MAIL,
                subject: `Delivery completed for ${delivery}`,
                html: htmlContent,
                attachments: [{ filename: fileName, content: fileContent, encoding: "base64" }]
            });

            return `Email sent successfully`;

        } catch (error) {

            console.error('Error sending email:', error);
            return `Error sending email: ${error.message}`;
        }
    })
})