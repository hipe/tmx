require 'skylab/pub-sub/emitter'
require 'skylab/porcelain/core'


module Skylab::Issue

  class Api::Action
    extend ::Skylab::PubSub::Emitter
    extend ::Skylab::Porcelain::AttributeDefiner
    extend ::Skylab::Porcelain::En::ApiActionInflectionHack

    meta_attribute :default
    meta_attribute :required


    attribute :issues_file_name, default: ISSUES_FILE_NAME

    attr_reader :client

    inflection.inflect.noun :singular

    def failed msg
      emit(:error, msg) # this might change to raising
      false
    end
    def initialize api
      @api = api
    end
    def info msg
      emit(:info, msg)
    end
    def invoke params=nil
      @params = params || {}
      execute # (maybe one day a slake- (rake-) like pattern)
    end
    attr_reader :invalid_reason
    def issues
      @issues ||= begin
        Models::Issues.new(
          :emitter => self,
          :manifest => @api.issues_manifest(issues_file_name)
        )
      end
    end
    def build_event type, data
      Api::MyEvent.new(type, data) { |o| o.inflection = self.class.inflection }
    end
    def params
      Hash[* @params_keys.map{ |k| [k, send(k)] }.flatten(1) ]
    end
    def params!
      self.class.attributes.tap do |attrs|
        attrs.each { |k, m| m.key?(:default) && ! @params.key?(k) and @params[k] = m[:default] }
        if (a = attrs.select{ |k, m| m[:required] && @params[k].nil? }.keys).any?
          return params_invalid("missing required parameter#{'s' if a.size != 1}: #{a.join(', ')}")
        end
      end
      @params_keys = @params.keys # for later reflection
      @params.each { |k, v| send("#{k}=", v) }
      @params = nil
      true
    end
    def params_invalid rsn
      @invalid_reason = rsn
      false
    end
    def wire!
      yield self
      self
    end
  end
end

