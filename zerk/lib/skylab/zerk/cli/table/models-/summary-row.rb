module Skylab::Zerk

  module CLI::Table

    module Models_::SummaryRow

      # no one in the system gets to know anything about the summary row
      # except the stream that actualy reads the real user mixed tuples..
      #
      # the series of N summary rows must be triggered only after (and
      # exactly after) the last mixed tuple has left the stream; so that
      # the mixed tuple that comes from the summary row will go thru the
      # ALMOST same pipeline as user tuples, with regard to pushing widths
      # etc.
      #
      # we say ALMOST because we probably want to turn off field
      # observation at this point (right?)
      #
      # when we effect the definion proc, we'll need a handle on the invo.

      class DefinitionCollection

        def initialize
          @_definitions = []
        end

        def freeze
          @_definitions.freeze
          super
        end

        def << defn
          @_definitions.push defn ; self
        end

        # -- read

        def build_tuple_stream_for_summary_rows_at_end_of_user_data invo

          TupleStream_via_AllYourMoney___.new( invo, @_definitions ).execute
        end
      end

      # ==

      class TupleStream_via_AllYourMoney___

        def initialize invo, defs
          @definitions = defs
          @invocation = invo
        end

        def execute
          @_gets = :__gets_first_one
          Common_.stream do
            send @_gets
          end
        end

        def __gets_first_one

          invo = @invocation
          if invo.has_field_observers
            invo.field_observers_controller.close_all_observation
          end
          @_definition_stream = Common_::Stream.via_nonsparse_array @definitions
          @_gets = :__gets_normally
          send @_gets
        end

        def __gets_normally

          defn = @_definition_stream.gets
          if defn
            _tuple = defn.to_mixed_tuple_for @invocation
            _tuple  # #todo
          else
            remove_instance_variable :@_gets
            NOTHING_
          end
        end
      end

      # ==

      class Definition

        def initialize p
          @_definition_proc = p
        end

        def to_mixed_tuple_for invo
          MixedTuple_via_Proc_and_Invocation___.new( @_definition_proc, invo ).execute
        end
      end

      # ==

      class MixedTuple_via_Proc_and_Invocation___

        def initialize p, invo
          @definition_proc = p
          @invocation = invo
        end

        def execute

          @__mixed_array = []
          @definition_proc[ self ]
          remove_instance_variable :@definition_proc
          remove_instance_variable :@invocation
          remove_instance_variable :@__mixed_array
        end

        def << x
          @__mixed_array.push x
          self
        end

        def read_observer sym
          @invocation.read_observer_ sym
        end
      end

      # ==
    end
  end
end
# #born during unification to replace ancient arch. that did similar
