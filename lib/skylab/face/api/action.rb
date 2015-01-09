module Skylab::Face

  class API::Action  # read [#058] the API action narrative :#intro

    # ~ section 2 events

    mutex = LIB_.module_lib.mutex  # #storypoint-10

    def has_emit_facet  # #storypoint-15
      true
    end

    def self.taxonomic_streams *a, &b
      API::Action::Emit[ self, :taxonomic_streams, a, b ]
    end

    def self.listeners_digraph *a, &b
      API::Action::Emit[ self, :listeners_digraph, a, b ]
    end

    def set_expression_agent x
      did = false
      @expression_agent ||= begin ; did = true ; x end
      did or fail "sanity - expression agent is write once."
      nil
    end

    attr_reader :expression_agent

  private

    def build_digraph_event * x_a, channel_i, esg

      _i_a = esg.ancestors( channel_i ).to_a

      if x_a.length.zero?
        EMPTY_WRAP___
      else
        self._DO_ME
      end
    end
    Wrap___ = ::Struct.new :payload_a
    EMPTY_WRAP___ = Wrap___.new

    def some_expression_agent
      @expression_agent or fail "sanity - expression agent was not set #{
        }set for this intance of #{ self.class }"
    end

    private :expression_agent
    alias_method :any_expression_agent, :expression_agent

  public

    # ~ section 3 services

    def has_service_facet  # fullfil [#027].
      false
    end

    define_singleton_method :services, mutex[ :services, -> *a do
      API::Action::Service[ self, a ]
    end ]

    # ~ section 4 parameters & normalization

    def has_param_facet  # fulfill [#027]
      false
    end

    # (predecessor to the function chain was removed with this line #posterity)

  private

    def field_box
      EMPTY_FIELD_BOX__
    end
    EMPTY_FIELD_BOX__ = LIB_.box.new.freeze

  public

    def absorb_params_using_message_yielder y, *a
      yy = LIB_.counting_yielder y.method :<<
      bx = field_box
      while a.length.nonzero?
        i = a.shift ; x = a.fetch 0 ; a.shift
        fld = bx.fetch i
        field_value_notify fld, x
        fld.has_normalizer and field_normalize yy, fld, x
      end
      yy.count.zero?
    end

    # `self.params` - rabbit hole .. er "facet" [#013]
    # placed here because it fits in semantically with the normalize
    # step of the API Action lifecycle.

    def self.meta_params * x_a
      ( @_meta_param_a ||= [ ] ).concat x_a
      nil
    end

    class << self
      attr_reader :_meta_param_a
      private :_meta_param_a
    end

    define_singleton_method :params, & mutex[ :params, ->( * a ) do
      # if you call this with empty `a`, it is the same as not calling it,
      # which gives you The empty field box above.
      if a.length.nonzero?
        # if it is a flat list of symbol names, that is shorthand for:
        if ! a.index { |x| ::Symbol != x.class }
          a.map! { |x| [ x, :arity, :one ] }
        end
        API::Params_.enhance_client_with_param_a_and_meta_param_a(
          self, a, _meta_param_a )
        nil
      end
    end ]

    API::Normalizer_.enhance_client_class self, :conventional
      # needed whether params or no

    # ~ facet 5.6x - metastories [#035] ~

    Magic_Touch_.enhance -> { API::Action::Metastory.touch },
      [ self, :singleton, :public, :metastory ]

  end
end
