Redmine::Plugin.register :redmine_bulk_creation do
  name 'Redmine Bulk Creation plugin'
  author 'Author name'
  description 'This is a plugin that create multiple issues at once'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'
end

Rails.application.config.to_prepare do
  Issue.send(:include, RedmineBulkCreation::IssuePatch)
  # ApplicationHelper.send(:include, RedmineBulkCreation::ApplicationHelperPatch)
  class RedmineBulkCreationHooks < Redmine::Hook::ViewListener
    render_on :view_issues_form_details_bottom, :partial=> 'issues/bulk_creation'
    def controller_issues_new_before_save(context = {})
      issue = context[:issue]
      params = context[:params]
      if  params[:issue][:create_bulk_issues] == '1'
        if issue.assigned_to.is_a?(Group)
          users = issue.assigned_to.users.select{|u| issue.assignable_users.include? u}
          issue.assigned_to_id = users.last.id

        end
      end
    end
    def controller_issues_new_after_save(context = {})
      issue = context[:issue]
      params = context[:params]
      if  params[:issue][:create_bulk_issues] == '1'
        issue.assigned_to_id = params[:issue][:assigned_to_id]
        if issue.assigned_to.is_a?(Group)
          users = issue.assigned_to.users.select{|u| issue.assignable_users.include? u}
          users.each do |user|
            if user != users.last
              @issue = Issue.new
              @issue.init_journal(User.current)
              @issue.bulk_copy_from(issue, :attachments => true, :watchers => true)
              # @issue.parent_issue_id = issue.parent_id
              @issue.assigned_to_id = user.id
              @issue.save
            end
          end
        end
      end

    end
  end
end