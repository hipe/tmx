module Skylab::Snag

  module API::Events

    Autoloader_[ self, :boxxy ]

    -> do  # `taxonomic_streams`
      memo = nil
      define_singleton_method :taxonomic_streams do
        memo ||= constants.map( & Snag_::Lib_::Name[]::FUN::Normify )
        #  e.g [:datapoint, :lingual, :structural ]
      end
    end.call

    module Datapoint
      def self.event graph, stream, act, x
        x
      end
      def self.call graph, stream, x
        # (hack it so it can be used as a factory by the yamilization node)
        x
      end
    end

    Structural = -> do
      o = Callback_::Event::Factory::Structural.new 5  # sanity - max
      class << o
        alias_method :snag_original_event, :event
        def event _, __, ___, payload_h
          snag_original_event _, __, payload_h
        end
      end
      o
    end.call
  end

  class API::Events::Lingual < Callback_::Event::Unified

    def initialize a, b, act, x
      @inflection = act.class.inflection
      set_render_under x
      super a, b
    end
  private
    def set_render_under x
      if x.respond_to? :can_render_under
        if x.can_render_under
          @can_render_under = true
          @text = nil
          @upstream_event = x
        else
          @can_render_under = false
          @text = nil
          @upstream_event = x
        end
      else
        @can_render_under = nil
        @text = x
        @upstream_event = nil
      end ; nil
    end
  public

    #         ~ nlp assistance hack ~

    attr_writer :inflection

    def inflected_noun
      @inflection.inflected.noun
    end

    def inflected_verb
      @inflection.inflected.verb
    end

    def noun_lexeme
      @inflection.lexemes.noun
    end

    def verb_lexeme
      @inflection.lexemes.verb
    end

    #         ~ experimental autonomously rendering events ~

    attr_reader :can_render_under

    def render_under x
      @upstream_event.render_under x
    end

    def fetch_text &otr
      if @text then @text
      elsif @upstream_event then @upstream_event.fetch_text(& otr )
      else
        ( otr || -> { raise ::RuntimeError, "no text" } )[]
      end
    end

    class << self
      alias_method :event, :new
    end
  end
end
