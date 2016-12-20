require 'spec_helper'
describe 'wpcli' do

  context 'with defaults for all parameters' do
    it { should contain_class('wpcli') }
  end
end
