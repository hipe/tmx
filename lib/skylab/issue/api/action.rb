require 'skylab/pub-sub/emitter'
require 'skylab/porcelain/attribute-definer'


module Skylab::Issue

  class Api::Action
    extend ::Skylab::PubSub::Emitter
    extend ::Skylab::Porcelain::AttributeDefiner

    meta_attribute :default
    meta_attribute :required


    attribute :issues_file_name, default: ISSUES_FILE_NAME

    attr_reader :client

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
      ev = Api::MyEvent.new(type, data)
      ev.minsky_frame = self
      ev
    end
    def params!
      self.class.attributes.tap do |attrs|
        attrs.each { |k, m| m.key?(:default) && ! @params.key?(k) and @params[k] = m[:default] }
        if (a = attrs.select{ |k, m| m[:required] && @params[k].nil? }.keys).any?
          return params_invalid("missing required parameter#{'s' if a.size != 1}: #{a.join(', ')}")
        end
      end
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

  # silly fun with inflections, but bad for i18n
  class << Api::Action
    def inflected_noun
      @inflected_noun ||= case verb_stem
        when 'list' ; noun_stem.plural
        else        ; noun_stem
      end
    end
    def noun_stem       ;  @noun_stem ||= NounStem[name_pieces[-2]]  end
    def verb_stem       ;  @verb_stem ||= VerbStem[name_pieces.last] end
    def name_pieces
      @name_pieces ||= begin
        to_s.gsub(/([a-z])([A-Z])/){ "#{$1}-#{$2}" }.downcase.split('::')
      end
    end
  end

  class VerbStem < String
    class << self   ; alias_method :[], :new end
    def progressive ; "#{self}ing"           end
  end

  class NounStem < String
    class << self   ; alias_method :[], :new end
    def plural      ; "#{self}s"             end # fine for now
  end

end

