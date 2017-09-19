require 'rails_helper'

class FakeController < ApplicationController
  include PageViewParamsValidator
end

RSpec.describe FakeController, type: :controller do

  describe '.validate' do

    context 'when valid date only params' do

      let(:params) do
        { date: '2017-09-12' }
      end

      it do
        expect(controller.valid_params?(params)).to be(true)
      end
    end

    context 'when invalid date only params' do

      let(:invalid_format_date) do
        { date: '9-12-2017' }
      end

      let(:invalid_date) do
        { date: '9-22-2017' }
      end

      it { expect(controller.valid_params?(invalid_format_date)).to be(false) }
      it { expect(controller.valid_params?(invalid_date)).to        be(false) }
    end


    context 'when valid start and end' do
      let(:params_one) do
        { start: '2017-09-14', end: '2017-09-15' }
      end

      let(:params_two) do
        { end: '2017-09-15' , start: '2017-09-14'}
      end

      it { expect(controller.valid_params?(params_one)).to be(true)  }
      it { expect(controller.valid_params?(params_two)).to be(true)  }
    end

    context 'when invalid start and end' do
      let(:params) do
        { start: '2017-09-14', end: '2017-29-15' }
      end

      it { expect(controller.valid_params?(params)).to be(false)  }
    end

    context 'when invalid combination of params' do

      let(:invalid_params_one) do
        { start: '2017-09-14', date: '2017-09-15' }
      end

      let(:invalid_params_two) do
        { end: '2017-09-14', date: '2017-09-15' }
      end

      let(:invalid_params_three) do
        { start: '2017-09-14', end: '2017-09-15' , date: '2017-09-15' }
      end

      it { expect(controller.valid_params?(invalid_params_one)).to   be(false)  }
      it { expect(controller.valid_params?(invalid_params_two)).to   be(false)  }
      it { expect(controller.valid_params?(invalid_params_three)).to be(false)  }

    end

  end
end
