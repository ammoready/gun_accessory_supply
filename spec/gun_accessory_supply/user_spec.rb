require 'spec_helper'

describe GunAccessorySupply::User do

  describe '#new' do
    it 'is invalid without the required options' do
      expect { GunAccessorySupply::User.new }.to raise_error(ArgumentError)
    end
  end

  describe '#authenticated?' do
    before do
      ftp = instance_double('Net::FTP', :passive= => true, :debug_mode= => true)
      allow(ftp).to receive(:chdir).with('Test/toBHC') { true }
      allow(Net::FTP).to receive(:open).with('ftp.host.com', 'usr', 'pass') { |&block| block.call(ftp) }
      allow(ftp).to receive(:pwd)
      allow(ftp).to receive(:close)
    end

    it { expect(GunAccessorySupply::User.new(username: 'usr', password: 'pass').authenticated?).to eq(true) }
  end

end
