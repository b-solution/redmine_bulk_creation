require_dependency 'issue'
module RedmineBulkCreation
  module IssuePatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        # Same as typing in the class.
        unloadable # Send unloadable so it will not be unloaded in development.

        attr_accessor :create_bulk_issues
      end
    end
  end

  module InstanceMethods
      def bulk_copy_from(arg, options={})
        issue = arg.is_a?(Issue) ? arg : Issue.visible.find(arg)
        self.attributes = issue.attributes.dup.except("id", "root_id", "parent_id", "lft", "rgt", "created_on", "updated_on", "status_id", "closed_on")
        self.custom_field_values = issue.custom_field_values.inject({}) {|h,v| h[v.custom_field_id] = v.value; h}
        if options[:keep_status]
          self.status = issue.status
        end
        self.author = User.current
        unless options[:attachments] == false
          self.attachments = issue.attachments.map do |attachement|
            attachement.copy(:container => self)
          end
        end
        unless options[:watchers] == false
          self.watcher_user_ids = issue.watcher_user_ids.dup
        end
        # @copied_from = issue
        @copy_options = options
        self
    end
  end
end
