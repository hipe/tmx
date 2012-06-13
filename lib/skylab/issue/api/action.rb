require 'skylab/pub-sub/emitter'
require 'skylab/porcelain/attribute-definer'


module Skylab::Issue

  class Api::Action
    extend ::Skylab::PubSub::Emitter
    extend ::Skylab::Porcelain::AttributeDefiner

    meta_attribute :required

    def failed msg
      emit(:error, msg) # this might change to raising
      false
    end

    def initialize api, context, &events
      @api = api
      @params = context
      events.call(self)
    end
    def internalize_params!
      valid? or return failed(invalid_reason)
      @internalized_param_keys = (a = [])
      @params.each { |k, v| a.push(k) ; self.send("#{k}=", v) }
      @params = nil
      true
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
          :manifest => @api.issues_manifest(issues_file_name)
        )
      end
    end
    def issues_file_name
      @issues_file_name || ISSUES_FILE_NAME
    end
    def build_event type, data
      ev = Api::MyEvent.new(type, data)
      ev.minsky_frame = self
      ev
    end
    def valid?
      _required = self.class.attributes.to_a.select{ |k, v| v[:required] }.map(&:first)
      if (nope = _required.select{ |k| @params[k].nil? and send(k).nil? }).any?
        @invalid_reason = "missing required parameter#{'s' if nope.size != 1}: #{nope.join(', ')}"
        return false
      end
      true
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

  class Api::MyEvent < ::Skylab::PubSub::Event
    def message= msg
      self.payload = msg # for now ..
    end
    attr_accessor :minsky_frame
    # silly fun
    def noun
      @minsky_frame.class.inflected_noun
    end
    def verb
      @minsky_frame.class.verb_stem
    end
  end

end

