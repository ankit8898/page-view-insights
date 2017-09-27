require 'rails_helper'

RSpec.describe PageViewsController, type: :controller do

  describe "GET #top_urls" do

    before(:context) { seed_test_data }

    context 'when looking for a date' do

      let(:date) { Date.today.strftime('%Y-%m-%d') }

      before do
        get :top_urls, params: {date: date}
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "return a JSON response with key as date looked up" do
        expect(json_body.collect(&:keys).flatten).to contain_exactly(date)
      end

      it "returns a single item" do
        expect(json_body).to have(1).items
      end

      it "returns a top url visited to date" do
        expect(Seeder::URLS).to include(json_body[0][date][0]['url'])
      end

      it "returns a top url visits" do
        expect(json_body[0][date][0]['visits']).to be > 0
      end

    end

    context 'when looking for a invalid date' do

      let(:date) { '2017-25-09'}

      before do
        get :top_urls, params: {date: date}
      end

      it "returns error message" do
        expect(json_body['message']).to eq("InValidParameters: For date range look up pass start and end. Eg: /top_urls?start=2017-09-13&end=2017-09-14. For a single day pass a date. Eg: /top_urls?date=2017-09-14")
      end
    end
  end

  describe "GET #top_referrers" do

    before(:context) { seed_test_data }

    context 'when looking for a date' do

      let(:date) { Date.today.strftime('%Y-%m-%d') }

      before do
        get :top_referrers, params: {date: date}
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "return a JSON response with key as date looked up" do
        expect(json_body.keys).to contain_exactly(date)
      end

      it "returns a collection of urls" do
        expect(json_body[date]).to have_at_least(1).items
      end
    end

    context 'when looking for a invalid date' do

      let(:date) { '2017-25-09'}

      before do
        get :top_referrers, params: {date: date}
      end

      it "returns error message" do
        expect(json_body['message']).to eq("InValidParameters: For date range look up pass start and end. Eg: /top_urls?start=2017-09-13&end=2017-09-14. For a single day pass a date. Eg: /top_urls?date=2017-09-14")
      end
    end
  end

end
