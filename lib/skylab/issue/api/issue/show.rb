module Skylab::Issue
  class Api::Issue::Show < Api::Action

    attribute :identifier
    attribute :issues_file_name, :required => true
    attribute :last

    emits :all,
      :error   => :all,
      :info    => :all,
      :payload => :all

    event_class Api::MyEvent

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
      items.while_counting.each do |item|
        emit :payload, my_yamlize(item, fields)
      end
      ct = items.last_count
      case ct
      when 0 ; emit(:info, "found no issues #{items.search.adjp}")
      when 1 ;
      else   ; emit(:info, "found #{ct} issues #{items.search.adjp}")
      end
    end
  end
end


