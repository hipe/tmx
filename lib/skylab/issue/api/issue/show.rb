module Skylab::Issue
  class Api::Issue::Show < Api::Action

    attribute :identifier,       :required => true
    attribute :issues_file_name, :required => true

    emits :all,
      :error   => :all,
      :info    => :all,
      :payload => :all

    muxer_event_class Api::MyEvent

    def execute
      internalize_params! or return false
      issues = self.issues.find(:identifier => identifier) or return issues
      a = issues.map { |i| i.dup } # flyweight ick
      _render_for_porcelain a
      a.size
    end

    def _render_for_porcelain arr
      @fields = [:identifier, :date, :message]
      case arr.size
      when 0 ; emit(:info, "found no issues with identifier: #{identifier.inspect}")
      when 1 ; _render_issue arr.first
      else   ; emit(:info, "found #{arr.size} issues with identifier #{identifier.inspect}")
               arr.each { |i| _render_issue(i) }
      end
    end

    def _render_issue issue
      emit :payload, my_yamlize(issue, @fields)
    end
  end
end

