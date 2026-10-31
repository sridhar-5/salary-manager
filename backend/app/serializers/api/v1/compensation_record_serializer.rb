module API
  module V1
    class CompensationRecordSerializer
      def self.versions_for(records)
        PaperTrail::Version
          .where(item_type: "CompensationRecord", item_id: records.map(&:id))
          .order(:created_at, :id)
          .group_by(&:item_id)
      end

      def self.admin_emails_for(versions)
        ids = versions.filter_map { |version| Integer(version.whodunnit, exception: false) }
        AdminUser.where(id: ids).pluck(:id, :email).to_h
      end

      def initialize(record, versions: nil, emails: nil)
        @record = record
        @versions = versions
        @emails = emails
      end

      def as_json
        loaded_versions = versions || record.versions.order(:created_at, :id).to_a
        loaded_emails = emails || self.class.admin_emails_for(loaded_versions)
        record.as_json(
          only: %i[id employee_id annual_salary effective_from effective_to created_at updated_at],
          include: {
            currency: { only: %i[id code name] },
            created_by: { only: %i[id email] }
          }
        ).merge("audit_events" => audit_events(loaded_versions, loaded_emails))
      end

      private

      attr_reader :record, :versions, :emails

      def audit_events(loaded_versions, loaded_emails)
        loaded_versions.map do |version|
          whodunnit_id = Integer(version.whodunnit, exception: false)
          {
            "event" => version.event,
            "at" => version.created_at,
            "whodunnit_email" => whodunnit_id && loaded_emails[whodunnit_id],
            "changes" => version.object_changes
          }
        end
      end
    end
  end
end
