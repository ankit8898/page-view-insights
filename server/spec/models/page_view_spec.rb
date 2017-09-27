require 'rails_helper'

RSpec.describe PageView, type: :model do

  describe '#validate' do

    context 'when valid input' do

      let(:url)          { Url.create(name: 'http://apple.com') }
      let(:referrer_url) { ReferrerUrl.create(name: 'www.google.com') }
      let(:valid_input) do
        { url_id: url.id, referrer_url_id: referrer_url.id }
      end

      before do
        @instance = described_class.create(valid_input)
      end

      it { expect(described_class.all).to have(1).items }
      it { expect(@instance.url.name).to           eq('http://apple.com') }
      it { expect(@instance.referrer_url.name).to  eq('www.google.com') }
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
