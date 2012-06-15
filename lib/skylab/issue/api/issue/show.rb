module Skylab::Issue
  class Api::Issue::Show < Api::Action

    attribute :identifier
    attribute :issues_file_name, :required => true
    attribute :last

    emits :all,
      :error   => :all,
      :info    => :all,
      :payload => :all,
      :error_with_manifest_line => :error


    event_class Api::MyEvent

    def execute
      params! or return
      query = {
        identifier: identifier,
        last: last
      }
      issues = self.issues.find(query) or return issues
      paint(issues)
    end

    FIELDS = [:identifier, :date, :message]

    def paint items
      @yamlize ||= Porcelain::Yamlizer.new(FIELDS) do |o|
        o.on_line         { |e| emit(:payload, e) }
      end
      items.with_count!.each do |item|
        if item.valid?
          @yamlize[item]
        else
          emit(:error_with_manifest_line, item.invalid_info)
        end
      end
      case (ct = items.last_count)
      when 0 ; emit(:info, "found no issues #{items.search.adjp}")
      when 1 ;
      else   ; emit(:info, "found #{ct} issues #{items.search.adjp}")
      end
    end
  end
end


