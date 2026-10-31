class API::V1::CompensationRecordsController < API::V1::ResourcesController
  before_action :set_employee
  load_and_authorize_resource through: :employee

  def index
    records = @compensation_records.includes(:currency, :created_by).order(effective_from: :desc, id: :desc)
    versions = API::V1::CompensationRecordSerializer.versions_for(records)
    emails = API::V1::CompensationRecordSerializer.admin_emails_for(versions.values.flatten)
    render json: {
      compensation_records: records.map { |item|
        API::V1::CompensationRecordSerializer.new(item, versions: versions[item.id] || [], emails: emails).as_json
      }
    }
  end

  def create
    CompensationRecords::Create.new(record, created_by: current_admin_user).call

    if record.persisted?
      render json: { compensation_record: API::V1::CompensationRecordSerializer.new(record).as_json }, status: :created
    else
      render_errors(record)
    end
  end

  private

  def set_employee
    @employee = Employee.find(params[:employee_id])
  end

  def compensation_record_params
    params.require(:compensation_record).permit(:annual_salary, :currency_id, :effective_from, :effective_to)
  end
end
