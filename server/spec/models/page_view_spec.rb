require 'rails_helper'

RSpec.describe PageView, type: :model do

  describe '.multi_insert' do

    let(:sample_page_view_entries) do
      [
        { url: 'http://apple.com', referrer: 'www.google.com' },
        { url: 'https://apple.com'},
        { url: 'http://developer.apple.com', referrer: 'www.apple.com' },
        { url: 'http://en.wikipedia.org', referrer: 'www.google.com' },
        { url: 'http://opensource.org', referrer: 'www.google.com' },
      ]
    end

    before do
      described_class.multi_insert(sample_page_view_entries)
    end

    it { expect(described_class.all).to have(5).items }
  end

  describe '#validate' do

    context 'when valid input' do

      let(:valid_input) do
        { url: 'http://apple.com', referrer: 'www.google.com' }
      end

      before do
        @instance = described_class.new(valid_input).save
      end

      it { expect(described_class.all).to have(1).items }
      it { expect(@instance.url).to       eq('http://apple.com') }
      it { expect(@instance.referrer).to  eq('www.google.com') }
    end


    context 'when invalid input' do

      let(:invalid_input) do
        { url: 'http://apple.com', referrer: 'abc.foo' }
      end

      before do
        @instance = described_class.new(invalid_input).save
      end

      xit { expect(described_class.all).to have(0).items }

    end


    describe '.errors' do

      context 'when invalid input' do

        let(:invalid_input) do
          { url: 'http://apple.com', referrer: 'abc.foo' }
        end

        before do
          @instance = described_class.new(invalid_input)
          @instance.valid?
        end

        it 'should have error messages' do
          expect(@instance.errors).to eq({:referrer=>["is not a valid URL"]})
        end


      end
    end
  end
end
