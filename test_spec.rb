require_relative 'spec_helper'

describe Test do
  describe 'blah' do
    it 'returns blah' do
      expect(Test.new.blah).to eq 'blah'
    end
  end
end
