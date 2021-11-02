require 'spec_helper'

describe GunAccessorySupply::Tracking do

  let(:tracking_params) { { username: 'ammoready', password: 'password', dealer_number: '12345' } }

  describe '.all' do
    before do
      tempfile = Tempfile.new(['12345_PackageTracking', '.csv'])
      FileUtils.copy_file(FixtureHelper.get_fixture_file('12345_PackageTracking.csv').path, tempfile.path)
      allow_any_instance_of(GunAccessorySupply::Tracking).to receive(:get_file) { tempfile }
    end

    it 'fetches tracking data' do
      tracking_detail = GunAccessorySupply::Tracking.fetch_data(tracking_params).first

      expect(tracking_detail[:po_number]).to eq('123456')
      expect(tracking_detail[:carrier]).to eq('UPS')
      expect(tracking_detail[:tracking_numbers]).to eq(['1Z068A950354921657'])
    end
  end

end
