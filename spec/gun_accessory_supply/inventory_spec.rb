require 'spec_helper'

describe GunAccessorySupply::Inventory do

  let(:credentials) { { username: '100001', password: 'pass' } }

  describe '.all' do
    before do
      tempfile = Tempfile.new(['exportXML_cq_barcodeFFL', '.csv'])
      FileUtils.copy_file(FixtureHelper.get_fixture_file('exportXML_cq_barcodeFFL.csv').path, tempfile.path)
      allow_any_instance_of(GunAccessorySupply::Inventory).to receive(:get_file) { tempfile }
    end

    it 'yields items' do
      count = 0
      GunAccessorySupply::Inventory.all(credentials) do |item|
        count += 1
        case count
        when 1
          expect(item[:item_identifier]).to eq('AU0001')
          expect(item[:quantity]).to eq(168)
          expect(item[:price]).to eq('3.5900')
        when 22
          expect(item[:item_identifier]).to eq('AU0022')
          expect(item[:quantity]).to eq(4)
          expect(item[:price]).to eq('64.9700')
        when 40
          expect(item[:item_identifier]).to eq('BA0040')
          expect(item[:quantity]).to eq(18)
          expect(item[:price]).to eq('8.9500')
        end
      end
    end
  end

  describe '.quantity' do
    before do
      tempfile = Tempfile.new(['exportXML_cq_barcodeFFL_all', '.csv'])
      FileUtils.copy_file(FixtureHelper.get_fixture_file('exportXML_cq_barcodeFFL_all.csv').path, tempfile.path)
      allow_any_instance_of(GunAccessorySupply::Inventory).to receive(:get_file) { tempfile }
    end

    it 'yields items' do
      count = 0
      GunAccessorySupply::Inventory.quantity(credentials) do |item|
        count += 1
        case count
        when 1
          expect(item[:item_identifier]).to eq('AU0001')
          expect(item[:quantity]).to eq(168)
        when 10
          expect(item[:item_identifier]).to eq('AU0010')
          expect(item[:quantity]).to eq(0)
        when 45
          expect(item[:item_identifier]).to eq('BA0045')
          expect(item[:quantity]).to eq(0)
        end
      end
    end
  end

end
