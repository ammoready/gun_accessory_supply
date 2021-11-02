require "spec_helper"

describe GunAccessorySupply do
  it "has a version number" do
    expect(GunAccessorySupply::VERSION).not_to be nil
  end

  describe "::Configuration" do
    before do
      GunAccessorySupply.configure do |config|
        config.ftp_host      = "ftp.host.com"
        config.top_level_dir = "Test"
      end
    end

    it { expect(GunAccessorySupply.config.ftp_host).to eq("ftp.host.com") }
  end
end
