require 'spec_helper'

describe GunAccessorySupply::Order do

  let(:credentials) { { username: '100001' } }
  let(:recipient) do
    {
      dealer_name: 'Night Ninja',
      ffl:         '12-aa-bb-1234',
      shipping: {
        name:    'Gretchen Manerly',
        address: '123 Grizzly Ln.',
        city:    'Sunnyville',
        state:   'SC',
        zip:     '29600',
        email:   'email@example.com',
        phone:   '888-999-1234'
      }
    }
  end

  describe '#add_recipient' do
    let(:order) { GunAccessorySupply::Order.new(credentials.merge(po_number: '100')) }

    before do
      order.add_recipient(recipient)
    end

    it { expect(order.filename).to match(/GAS-100-#{Time.now.strftime('%Y%m%d')}/) }
  end

  describe '#add_item' do
    let(:order) { GunAccessorySupply::Order.new(credentials.merge(po_number: '100')) }
    let(:item) {
      {
        identifier: 'EE00011',
        description: 'Cool Mag',
        upc: '123000000001',
        qty: 1,
        price: '100.40',
      }
    }

    before do
      order.add_recipient(recipient)
      order.add_item(item)
    end

    it { expect(order.instance_variable_get(:@items).length).to eq(1) }
  end

  describe '#to_csv' do
    let(:sample_order) { FixtureHelper.get_fixture_file('sample_order.csv').read }
    let(:order) { GunAccessorySupply::Order.new(credentials.merge(po_number: '100')) }
    let(:item) {
      {
        identifier: 'EE00011',
        description: 'Cool Mag',
        upc: '123000000001',
        qty: 1,
        price: '195.00',
      }
    }

    before do
      order.add_recipient(recipient)
      order.add_item(item)
    end

    it { expect(order.to_csv).to eq(sample_order) }
  end

end
