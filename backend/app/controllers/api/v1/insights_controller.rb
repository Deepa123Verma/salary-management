
module Api
  module V1
    class InsightsController < ApplicationController
      def by_country
        render json: { data: insights.by_country }
      end

      def by_department
        render json: { data: insights.by_department }
      end

      def by_job_title
        render json: { data: insights.by_job_title(country: params[:country]) }
      end

      def distribution
        buckets = params.fetch(:buckets, 5).to_i.clamp(1, 20)
        render json: { data: insights.distribution(buckets: buckets) }
      end

      private

      def insights
        @insights ||= SalaryInsights.new
      end
    end
  end
end