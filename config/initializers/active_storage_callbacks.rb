# frozen_string_literal: true

# Callbacks for ActiveStorage::Attachment to update record popularity scores
# when images or songs are added or removed.
#
# This hooks into the attachment lifecycle to trigger background jobs
# that recalculate the popularity score for affected records.

Rails.application.config.after_initialize do
  ActiveStorage::Attachment.class_eval do
    after_create_commit :schedule_popularity_update
    after_destroy_commit :schedule_popularity_update

    private

    def schedule_popularity_update
      return unless record_type == "Record"
      return unless name.in?(%w[images songs])

      RecordPopularityJob.perform_later(record_id)
    end
  end
end
