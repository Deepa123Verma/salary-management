module Api
  module V1
    class EmployeesController < ApplicationController
      MAX_PER_PAGE = 100
      DEFAULT_PER_PAGE = 25

      before_action :set_employee, only: %i[show update destroy]

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

      def show
        render json: @employee
      end

      def create
        employee = Employee.new(employee_params)
        if employee.save
          render json: employee, status: :created
        else
          render_errors(employee)
        end
      end

      def update
        if @employee.update(employee_params)
          render json: @employee
        else
          render_errors(@employee)
        end
      end

      def destroy
        @employee.destroy
        head :no_content
      end

      private

      def set_employee
        @employee = Employee.find(params[:id])
      end

      def employee_params
        params.require(:employee).permit(:full_name, :email, :job_title, :department, :country, :currency, :salary_cents, :hired_on, :status)
      end

      def render_errors(employee)
        render json: { errors: employee.errors.full_messages },
                status: :unprocessable_entity
      end
      end
    end
  end