require 'rails_helper'

RSpec.describe PageView, type: :model do

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
  end

  describe '.errors' do

    context 'when invalid input' do

      let(:invalid_input) do
        { url: 'abc.com', referrer: 'abc.foo' }
      end

      before do
        @instance = described_class.new(invalid_input)
        @instance.valid?
      end

      it 'should have error messages' do
        expect(@instance.errors).to eq({:url=>["is not a valid URL"]})
      end
    end

    context 'when valid input' do

      let(:invalid_input) do
        { url: 'http://abc.com', referrer: 'abc.foo' }
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

  describe '.after_create' do

    xit 'should update the hash with MD5' do
    end
  end

  describe '#top_urls' do

    context 'Date lookup' do
      before(:context) { seed_test_data }

      context 'when valid date' do

        let(:params) do
          { date: Date.today.strftime('%Y-%m-%d') }
        end
        it { expect(PageView.top_urls(params)).to have(1).items }
      end

      context 'when invalid date' do

        let(:params) do
          { date: 5.days.from_now.strftime('%Y-%m-%d') }
        end
        it { expect(PageView.top_urls(params)).to have(0).items }
      end
    end

    context 'Between start and end' do
      before(:context) { seed_test_data }

      context 'when valid_date range' do

        let(:params) do
          { start: 4.days.ago.strftime('%Y-%m-%d'), end: Date.today.strftime('%Y-%m-%d') }
        end

        it { expect(PageView.top_urls(params)).to have(5).items }

      end
    end
  end
end
