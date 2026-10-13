module Api
  module V1
    class EmployeesController < ApplicationController
      MAX_PER_PAGE = 100
      DEFAULT_PER_PAGE = 25

      def index
        scope = Employee.in_country(params[:country])
                        .in_department(params[:department])
                        .with_status(params[:status])
                        .search(params[:q])

        page      = [params.fetch(:page, 1).to_i, 1 ].max
        per_page  = params.fetch(:per_page, DEFAULT_PER_PAGE).to_i.clamp(1, MAX_PER_PAGE)
        total     = scope.count
        employees = scope.order(:id).limit(per_page).offset((page - 1) * per_page)

        render json: {
          data: employees,
          meta: { page: page, per_page: per_page, total: total }
        }
      end
    end
  end
end