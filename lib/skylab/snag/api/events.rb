module Skylab::Snag

  module API::Events

    MetaHell::Boxxy[ self ]

    -> do  # `taxonomic_streams`
      memo = nil
      define_singleton_method :taxonomic_streams do
        memo ||= constants.map( & Headless::Name::FUN.normify )
        #  e.g [:datapoint, :lingual, :structural ]
      end
    end.call

    module Datapoint
      def self.event graph, stream, act, x
        x
      end
      def self.call graph, stream, x
        # (hack it so it can be used as a factory by CLI::Services::Yamlization)
        x
      end
    end

    Structural = -> do
      o = PubSub::Event::Factory::Structural.new 5  # sanity - max
      class << o
        alias_method :snag_original_event, :event
        def event _, __, ___, payload_h
          snag_original_event _, __, payload_h
        end
      end
      o
    end.call
  end

  class API::Events::Lingual < PubSub::Event::Unified

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

    def initialize a, b, act, x
      super a, b
      @inflection = act.class.inflection
      @can_render_under =
      if x.respond_to? :can_render_under
        if x.can_render_under
          @upstream_event = x
          @text = nil
          true
        else
          @upstream_event = x
          @text = nil
          false
        end
      else
        @upstream_event = nil
        @text = x
        nil
      end
    end
  end
end
