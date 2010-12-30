require File.join(File.dirname(__FILE__), 'spec_helper')

describe "API" do
  before do
    @config_file_path = File.join(File.dirname(__FILE__), 'config', 'config.example.yml')
  end

  it "can load the config file" do
    lambda do
      Api.config
    end.should raise_exception

    Api.config = @config_file_path
    Api.config.should_not be_nil
  end

end
