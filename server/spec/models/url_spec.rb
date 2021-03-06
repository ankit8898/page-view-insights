require 'rails_helper'

RSpec.describe Url, type: :model do

  describe '.errors' do

    context 'when invalid input' do

      let(:invalid_input) do
        { name: 'abc.com' }
      end

      before do
        @instance = described_class.new(invalid_input)
        @instance.valid?
      end

      it 'should have error messages' do
        expect(@instance.errors).to eq({:name => ["is not a valid URL"]})
      end
    end

    context 'when valid input' do

      let(:invalid_input) do
        { name: 'http://abc.com'}
      end

      before do
        @instance = described_class.new(invalid_input)
        @instance.valid?
      end

      it 'should have no error messages' do
        expect(@instance.errors).to be_empty
      end
    end
  end
end
