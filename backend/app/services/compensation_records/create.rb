module CompensationRecords
  class Create
    def initialize(record, created_by:)
      @record = record
      @created_by = created_by
    end

    def call
      record.created_by = created_by
      record.currency ||= record.employee.country.currency

      begin
        CompensationRecord.transaction do
          close_previous_open_records if record.valid?
          raise ActiveRecord::Rollback unless record.save
        end
      rescue ActiveRecord::RecordInvalid => exception
        record.errors.add(:base, exception.record.errors.full_messages.to_sentence)
      end

      record
    end

    private

    attr_reader :record, :created_by

    def close_previous_open_records
      record.employee.compensation_records
        .where("effective_from < ?", record.effective_from)
        .where("effective_to IS NULL OR effective_to >= ?", record.effective_from)
        .find_each do |previous|
          previous.update!(effective_to: record.effective_from - 1.day)
        end
    end
  end
end
