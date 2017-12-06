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

          foc = @invocation.field_observers_controller__
          if foc
            foc.close_all_observation
          end

          @_definition_stream = Stream_[ @definitions ]
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
          RowControllerForClient__.new( @_definition_proc, invo ).execute
        end
      end

      # ==

      class RowControllerForClient__  # now a pattern, #table-spot-4

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

#==BEGIN GUEST - common implementations for field observers

      #  - these are here because in practice the results of these common
      #    observer implementations are always presented in summary rows.
      #
      #  - we don't call these "functions" because we want to discourage
      #    the thinking that they represent some sort of "call" at a
      #    discrete moment in time. rather, we wish to promote the idea
      #    that they are just "observers" that (typically) accumulate
      #    (reduce) something into some single value, a value which can
      #    be read at any time, and perhaps multiple times (like a
      #    a checking account balance being read from an app).
      #
      #    in practice these are typically called from summary rows and
      #    summary rows are resolved from special hooks called only once
      #    all the pages of input have been read. because of this, these
      #    can "feel" like an Excel spreadsheet function; but we want to
      #    promote the idea that creating such an observer is only half
      #    the picture - the other half is reading and presenting the
      #    observer's data, something that is not provided out of the box
      #    with these items. so to think of them as functions might be
      #    a leaky abstraction.
      #
      #  - be prepared for these to move up to [tab] in some
      #    fantastical world where there is a reason to.
      #
      #  - or maybe we'll move to a "lookup softly" model where we get
      #    first try at resolving the name, and the other lib gets final try.

      Dereference_common_field_observer = -> const do

        CommonFieldObservers___.const_get const, false
      end

      # ==

      module CommonFieldObservers___

        # (#spot1.8 references a "max" implementation in the wild)

        CountTheNonEmptyStrings = -> o do

          count = 0

          o.on_typified_mixed do |tm|
            if :string == tm.typeish_symbol
              # hi.
              if EMPTY_STRING_RX___ !~ tm.value
                count += 1
              end
            end
          end

          o.read_observer_by do
            count
          end
        end

        SumTheNumerics = -> o do

          # because summary results are often written "by hand" #wish [#057]
          # we want it to "just work" that if only integers go into the sum,
          # the accumulator (when read) is also an integer, such that the
          # accumulator `to_s`'s in an unsurprising manner.
          #
          # but any first float "upcasts" the accumulator to a float,
          # irrevocably.
          #
          # this is NOT so smart that if you have e.g 1.6 then 1.4, that
          # the result would then "downcast" to 3 instead of 3.0. it does
          # not do that.

          total_x = 0

          simpler_p = nil
          p = -> tm do
            if tm.is_numeric
              case tm.typeish_symbol
              when :nonzero_integer
                total_x += tm.value
              when :zero
                NOTHING_
              when :nonzero_float
                total_x = total_x.to_f
                p = simpler_p
                total_x += tm.value
              else
                hole
              end
            end
          end

          simpler_p = -> tm do
            if tm.is_numeric
              total_x += tm.value
            end
          end

          o.on_typified_mixed do |tm|
            p[ tm ]
          end

          o.read_observer_by do
            total_x
          end
        end
      end

      # ==

      EMPTY_STRING_RX___ = /\A[[:space:]]*\z/  # #table-spot-temp-1

      # ==

#==END GUEST

    end
  end
end
# #born during unification to replace ancient arch. that did similar
