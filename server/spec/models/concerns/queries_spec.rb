require 'rails_helper'

RSpec.describe Queries, type: :concern do

  class DummyPageView < PageView
    extend Queries
  end

  describe "Scopes" do

    describe 'CREATED_AT_SCOPE' do

      let(:date) { '2017-09-12' }

      it 'should be a type proc' do
        expect(described_class::CREATED_AT_SCOPE).to be_kind_of(Proc)
      end

      it 'should be of type Sequel::LiteralString' do
        expect(described_class::CREATED_AT_SCOPE.call(date)).to be_kind_of(Sequel::LiteralString)
      end

      it 'should return the string of where clause' do
        expect(described_class::CREATED_AT_SCOPE.call(date)).to eq("date_trunc('day', created_at)::DATE =  '#{date}'")
      end
    end

    describe 'CREATED_AT_RANGE_SCOPE' do

      let(:start_date) { '2017-09-12' }
      let(:end_date)   { '2017-09-13' }

      it 'should be a type proc' do
        expect(described_class::CREATED_AT_RANGE_SCOPE).to be_kind_of(Proc)
      end

      it 'should be of type Sequel::LiteralString' do
        expect(described_class::CREATED_AT_RANGE_SCOPE.call(start_date, end_date)).to be_kind_of(Sequel::LiteralString)
      end

      it 'should return the string of where clause' do
        expect(described_class::CREATED_AT_RANGE_SCOPE.call(start_date, end_date)).to eq("date_trunc('day', created_at)::DATE BETWEEN '#{start_date}' AND '#{end_date}'")
      end

    end

    describe 'SELECTED_COLUMNS_SCOPE' do

      before(:all) do
        @output = described_class::SELECTED_COLUMNS_SCOPE.call
      end

      it { expect(@output[0]).to            eq(:url) }
      it { expect(@output[1].expression).to eq("date_trunc('day', created_at)::DATE") }
      it { expect(@output[1].alias).to      eq(:date_visited) }
      it { expect(@output[2].expression).to eq("count(*)") }
      it { expect(@output[2].alias).to      eq(:visits) }
    end

    describe '#top_urls_on_date_query' do

      it { expect(DummyPageView.top_urls_on_date_query('2017-09-17').sql.gsub(/\"/,"'")).to eq(
        "SELECT 'url', date_trunc('day', created_at)::DATE AS 'date_visited', count(*) AS 'visits' FROM 'page_views' WHERE (date_trunc('day', created_at)::DATE =  '2017-09-17') GROUP BY 'date_visited', 'url' ORDER BY 'visits' DESC LIMIT 1"
        ) }
    end

    describe '#top_urls_between_date_query' do
      it { expect(DummyPageView.top_urls_between_date_query('2017-09-15','2017-09-16').sql.gsub(/\"/,"'")).to eq(
        "SELECT 'url', date_trunc('day', created_at)::DATE AS 'date_visited', count(*) AS 'visits' FROM 'page_views' WHERE (date_trunc('day', created_at)::DATE BETWEEN '2017-09-15' AND '2017-09-16') GROUP BY 'date_visited', 'url'"
        ) }
    end
  end

end
