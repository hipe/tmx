module Skylab::Issue
  class Api::Issue::Number::List < Api::Action

    attribute :issues_file_name, :required => true

    emits :all, :error => :all, :info => :all, :payload => :all

    muxer_event_class Api::MyEvent

    def execute
      @params[:issues_file_name] ||= ISSUES_FILE_NAME
      valid? or return failed(invalid_reason)
      num = issues.numbers { |num| emit(:payload, num) }
      emit(:info, "(#{num} issues found.)")
      true
    end
  end
end

