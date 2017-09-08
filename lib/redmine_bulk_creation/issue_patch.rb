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

  end
end
