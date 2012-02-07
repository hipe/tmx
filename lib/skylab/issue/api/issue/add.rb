module Skylab::Issue
  class Api::Issue::Add < Api::Action

    attribute :dry_run
    attribute :issues_file_name, :required => true
    attribute :message,          :required => true

    emits :all, :error => :all, :info => :all, :payload => :all

    muxer_event_class Api::MyEvent

    def execute
      @params[:issues_file_name] ||= ISSUES_FILE_NAME
      valid? or return failed(invalid_reason)
      issues.add(@params[:message], :dry_run => @params[:dry_run])
    end
  end
end

