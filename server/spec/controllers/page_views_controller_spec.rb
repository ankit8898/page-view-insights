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
        expect(json_body.keys).to contain_exactly(date)
      end

      it "returns a single item" do
        expect(json_body[date]).to have(1).items
      end

      it "returns a top url visited to date" do
        expect(Seeder::URLS).to include(json_body[date][0]['url'])
      end

      it "return a JSON response with key as date looked up" do
        expect(json_body.keys).to contain_exactly(date)
      end
    end
  end

end
