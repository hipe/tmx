require 'skylab/slake/muxer'
require 'skylab/slake/attribute-definer'

module Skylab::Issue
  class Api::Action
    extend ::Skylab::Slake::Muxer
    extend ::Skylab::Slake::AttributeDefiner

    meta_attribute :required

    def failed msg
      emit(:error, msg) # this might change to raising
      false
    end

    def initialize api, context, &events
      @api = api
      @params = context
      instance_eval(&events)
    end
    def invoke
      execute # (maybe one day a slake- (rake-) like pattern)
    end
    attr_reader :invalid_reason
    def issues
      @issues ||= begin
        require "#{ROOT}/models/issues"
        Models::Issues.new(
          :emitter => self,
          :manifest => @api.issues_manifest(@params[:issues_file_name])
        )
      end
    end
    def muxer_build_event type, data
      ev = Api::MyEvent.new(type, data)
      ev.verb = name
      ev.noun = "issue"
      ev
    end
    def name
      self.class.to_s.match(/(?::|^)([^:]+)$/)[1].gsub(/([a-z])([A-Z])/){ "#{$1}-#{$2}" }.downcase
    end
    def valid?
      _required = self.class.attributes.to_a.select{ |k, v| v[:required] }.map(&:first)
      if (nope = _required.select{ |k| @params[k].nil? }).any?
        @invalid_reason = "missing required parameter#{'s' if nope.size != 1}: #{nope.join(', ')}"
        return false
      end
      true
    end
  end

  class Api::MyEvent < ::Skylab::Slake::Muxer::Event
    attr_writer :data
    attr_accessor :handled
    alias_method :handled?, :handled
    def handled! ; @handled = true ; self end
    alias_method :message=, :data=
    attr_accessor :noun
    attr_accessor :verb
  end

end

