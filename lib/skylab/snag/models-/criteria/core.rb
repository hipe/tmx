module Skylab::Snag

  class Models_::Criteria

    PERSISTED_CRITERIA_FILENAME___ = 'data-documents-/persisted-criteria'

    Brazen_ = Snag_.lib_.brazen

    Actions = ::Module.new

    Action__ = Brazen_::Model.common_action_class

    class Actions::Criteria_To_Stream < Action__

      Brazen_::Model.common_entity self,

        :required,
        :property, :upstream_identifier,

        :required,
        :argument_arity, :one_or_more,
        :property, :criteria

      def produce_result

        h = @argument_box.h_

        c = Criteria_.new_via_expression(
          h.fetch( :criteria ),
          @kernel,
          & handle_event_selectively )

        if c
          c.to_reduced_entity_stream_via_collection_identifier(
            h.fetch( :upstream_identifier ) )
        else
          c
        end
      end
    end

    class Actions::To_Criteria_Stream < Action__

      def produce_result

        @kernel.silo( :criteria )._cc.to_entity_stream
      end
    end

    class Silo_Daemon

      def initialize kr, _mod

        @_kr = kr
      end

      def _cc

        @__cc ||= Brazen_::Data_Stores:: Directory_as_Collection.new(
          @_kr
        ) do | o |

          o.directory_is_assumed_to_exist = false

          o.directory_path = Snag_.dir_pathname.join(
            PERSISTED_CRITERIA_FILENAME___
          ).to_path

          o.filename_pattern = /\A[a-z0-9]+(?:[-_][a-z0-9]+)*\z/i

          o.filesystem = Snag_.lib_.system.filesystem

          o.flyweight_class = Criteria_

        end
      end

      def EN_domain_adapter

        @__eda ||= Criteria_::Library_::Domain_Adapter.
          new_via_kernel_and_NLP_const( @_kr, :EN )
      end
    end


    # -> ( criteria model )

      class << self

        def new_flyweight kr, & x_p
          new kr, & x_p
        end

        def new_via_expression x, kr, & x_p

          c = new kr, & x_p
          ok = c.__receive_criteria_expression x
          if ok
            c
          else
            ok
          end
        end

        def properties
          Properties___[]
        end

        private :new
      end  # >>

      Properties___ =  Callback_.memoize do  # a sketch for front client integ.
        [
          Callback_::Actor.methodic.simple_property_class.new_via_name_symbol(
            :name
          )
        ].freeze
      end

      def initialize k, & oes_p

        @kernel = k
        @on_event_selectively = oes_p
        @ok = true
      end

      # ~ for listing persisted critiera

      def reinitialize_via_path_for_directory_as_collection path
        @__path = path
        NIL_
      end

      def property_value_via_symbol sym
        send :"__#{ sym }__property_value"
      end

      def __name__property_value
        ::File.basename @__path
      end

      # ~

      def __receive_criteria_expression x

        _ct = if x.respond_to? :value_x
          x
        else

          @kernel.silo( :criteria ).EN_domain_adapter.
            new_criteria_tree_via_word_array(
              x, & @on_event_selectively )
        end

        _receive _ct, :criteria_tree
      end

      def __receive_trueish__criteria_tree__ ct

        @criteria_tree =  ct

        _mc = @kernel.unbound_via_normal_identifier(
          @criteria_tree.name_x )

        remove_instance_variable :@kernel  # ick/meh

        _receive _mc, :model_class
      end

      def __receive_trueish__model_class__ mc

        @model_class = mc

        _expad = mc::Expression_Adapters::Criteria_Tree

        _receive _expad, :expression_adapter
      end

      def to_proc
        @_criteria_proc
      end

      def __receive_trueish__expression_adapter__ expad

        _lookup_p = expad.method :lookup_associated_model_

        @_criteria_proc = @criteria_tree.value_x.to_criteria_proc_under_ _lookup_p

        ACHIEVED_
      end

      def to_reduced_entity_stream_via_collection_identifier id_x

        col = @model_class.collection_module_for_criteria_resolution.

          new_via_upstream_identifier( id_x, & @on_event_selectively )

        if col
          to_reduced_entity_stream_against_collection col
        else
          col
        end
      end

      def to_reduced_entity_stream_against_collection col

        st = col.to_entity_stream( & @on_event_selectively )

        if st
          __to_reduced_entity_stream_against_entity_stream st
        else
          st
        end
      end

      def __to_reduced_entity_stream_against_entity_stream st

        p = @_criteria_proc

        st.reduce_by do | node |
          p[ node ]
        end
      end

      def _receive x, sym

        if x
          send :"__receive_trueish__#{ sym }__", x
        else
          @ok = x
          x
        end
      end

      # <-

    module Expression_Adapters
      EN = nil
    end

    Criteria_ = self
  end
end
