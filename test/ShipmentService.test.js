const cds = require('@sap/cds')

const { GET, POST, expect, axios } = cds.test (__dirname+'/..')
axios.defaults.auth = { username: 'alice', password: '' }

describe('OData APIs', () => {

  it('serves ShipmentService.Deliveries', async () => {
    const { data } = await GET `/odata/v4/shipment/ShipmentService.Deliveries ${{ params: { $select: 'ID,deliveryID' } }}`
    expect(data.value).to.containSubset([
      {"ID":"29740646-0ab2-4f6e-af54-11ee809dc4b5","deliveryID":"D-29740646"},
    ])
  })

  it('executes updateShipmentStatus', async () => {
    const { data } = await POST `/odata/v4/shipment/updateShipmentStatus ${
      {"status":"status-21228832"}
    }`
    // TODO finish this test
    // expect(data.value).to...
  })
})
