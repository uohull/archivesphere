module Auditable
  extend ActiveSupport::Concern

  included do
    has_metadata "audit_log", type: Audit
    attr_accessor :content_will_update, :working_user

    before_save do
      if content_will_update
        self.log_audit(working_user, "Content updated: #{content_will_update}")
        self.content_will_update = nil
      elsif metadata_streams.any? { |ds| ds.changed? }
        self.log_audit(working_user, "Metadata updated #{metadata_streams.select { |ds| ds.changed? }.map{ |ds| ds.dsid}.join(', ')}")
      end
    end
  end

  
  def log_audit(user, what)
    return unless user
    audit_log.who = user.user_key
    audit_log.what = what
    audit_log.when = DateTime.now
  end
end
