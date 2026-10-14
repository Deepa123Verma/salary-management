module Api
  module V1
    class InsightsController < ApplicationController
      def by_country
        render json: { data: SalaryInsights.new.by_country }
      end
    end
  end
end
