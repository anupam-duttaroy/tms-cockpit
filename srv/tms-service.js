const cds = require('@sap/cds')

module.exports = cds.service.impl(async function() {
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
})