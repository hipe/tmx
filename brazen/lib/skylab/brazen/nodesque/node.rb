module Skylab::Brazen

  class Nodesque::Node

    # currently this is a would-be abstract base class expected only to be
    # used for the "model" and "action" (traditional) nodes in the reactive
    # model. the categories below are pursuant to [#024].

    # -- Actionability - identity in & navigation of the reactive model --

    def self.adapter_class_for _  # moda. specific hook for hax
      NIL_
    end

    def kernel
      @kernel
    end

    def accept_parent_node x
      @parent_node = x ; nil
    end

    # -- Description, inflection & name --

    class << self

      attr_accessor :description_block

      def process_some_customized_inflection_behavior upstream
        name_function_lib::Inflection.new( upstream, self ).execute
      end

      def name_function
        @name_function ||= name_function_class::Build_name_function[ self ]
          # ivar name is :+#public-API
      end
    end  # >>

    def has_description
      ! self.class.description_block.nil?
    end

    def under_expression_agent_get_N_desc_lines expag, d=nil  # assume has

      N_lines_[ [], d, [ self.class.description_block ], expag ]
    end

    def name
      self.class.name_function
    end

    # -- Placement & visibility --

    class << self

      attr_accessor(
        :after_name_symbol,
        :is_promoted,
      )
    end # >>

    def after_name_symbol
      self.class.after_name_symbol
    end

    def is_visible
      true
    end

    # -- Preconditions --

    class << self

      attr_accessor :precondition_controller_i_a_

      def preconditions
        @__did_resolve_pcia ||= resolve_precondition_controller_identifer_array
        @preconditions
      end
    end

    # -- Properties - these :#hook-out's MUST get overridden by property lib --

    ## ~~ readers (narrated)

    def to_qualified_knownness_stream_

      foz = formal_properties

      if foz

        sym_a = foz.get_names
        sym_a.sort!

        Callback_::Stream.via_nonsparse_array( sym_a ).map_by do | sym |

          qualified_knownness sym
        end
      else
        Callback_::Stream.the_empty_stream
      end
    end

    def formal_properties
      self.class.properties
    end

    class << self

      def properties
        NIL_  # by default you have none, be you action or model
      end
    end

    def knowness_via_association_ prp

      knownness prp.name_symbol
    end

    def qualified_knownness sym

      had = true
      x = as_entity_actual_property_box_.fetch sym do
        had = false
      end

      Callback_::Qualified_Knownness.via_value_and_had_and_association(
        x, had, formal_properties.fetch( sym ) )
    end

    def knownness sym

      had = true
      x = as_entity_actual_property_box_.fetch sym do
        had = false
      end

      if had
        Callback_::Known_Known[ x ]
      else
        Callback_::KNOWN_UNKNOWN
      end
    end

    ## ~~ writers ( & related )

    define_method :process_polymorphic_stream_fully, PPSF_METHOD_
    ppsp = :process_polymorphic_stream_passively
    define_method ppsp, PPSP_METHOD_
    private ppsp

    def receive_missing_required_properties_event ev

      # [#001]:#stowaway-1 explains why this method is here

      raise ev.to_exception
    end

    ## ~~ editing your node's set of *formal* properties

    class << self

      def edit_entity_class * x_a, & edit_p

        # (block is used in one place in [ts] at writing)

        _what = entity_enhancement_module

        o = Home_::Entity::Session.new
        o.arglist = x_a
        o.client = self
        o.extmod = _what
        o.block = edit_p
        o.execute
      end
    end

    # ~ event receiving & sending

    private def maybe_send_event * i_a, & ev_p

      handle_event_selectively[ * i_a, & ev_p ]
    end

    def handle_event_selectively  # idiomatic accessor for this, :+#public-API

      @on_event_selectively
    end
  end
end
