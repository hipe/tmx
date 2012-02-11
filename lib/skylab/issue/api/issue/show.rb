module Skylab::Issue
  class Api::Issue::Show < Api::Action

    attribute :identifier
    attribute :issues_file_name, :required => true
    attribute :last

    emits :all,
      :error   => :all,
      :info    => :all,
      :payload => :all

    muxer_event_class Api::MyEvent

    def execute
      internalize_params! or return false
      query = {
        identifier: identifier,
        last: last
      }
      issues = self.issues.find(query) or return issues
      paint(issues)
    end

    FIELDS = [:identifier, :date, :message]

    def paint items
      fields = FIELDS
      ct = 0
      items.each do |item|
        ct += 1
        emit :payload, my_yamlize(item, fields)
      end
      case ct
      when 0 ; emit(:info, "found no issues #{items.search.adjp}")
      when 1 ;
      else   ; emit(:info, "found #{ct} issues #{items.search.adjp}")
      end
    end
  end
end


