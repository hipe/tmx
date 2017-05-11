module Skylab::TanMan

  module Models_::Meaning

    class MeaningsOperatorBranchFacade_

      def initialize dc

        __init_string_array_via_digraph_controller dc
      end

      def into_node_apply_meaning_by_

        Here_::Magnetics_::ApplyMeaning_via_Node_and_Meaning.call_by do |o|
          yield o
          o.mutable_digraph = @__mutable_digraph
          o.meanings_operator_branch = self
        end
      end

      def add_meaning_by_

        # entity on success. false-ish on failure

        Here_::Magnetics_::PersistMeaning_via_Meaning_and_Collection.call_by do |o|
          yield o
          o.fallback_mutable_string = @fallback_mutable_string
          o.entity_stream_by = method :to_meaning_entity_stream_
        end
      end

      def __init_string_array_via_digraph_controller dc  # (legacy placement)

        sx = dc.graph_sexp

          if ! sx.e6
            sx.e6 = ""  # MEH - make life easier by guaranteeing at least one editable
          end

          @fallback_mutable_string = sx.e6

          s_a = []
          [ :e0, :e6, :e10 ].each do | sym |
            x = sx[ sym ]
            x || next
            s_a.push x
          end

        @_string_array = s_a

        @__mutable_digraph = dc
        NIL
      end

      def one_entity_against_natural_key_fuzzily_ name_s, & p
        Home_::ModelMagnetics_::OneEntity_via_NaturalKey_Fuzzily.call_by do |o|
          o.natural_key_head = name_s
          o.entity_stream_by = method :to_meaning_entity_stream_
          o.model_module = Here_
          o.listener = p
        end
      end

      def to_meaning_entity_stream_

        # (was: `to_stream_of_meanings_with_mutable_string_metadata`)
        # (would-be API method `to_dereferenced_item_stream`)

          # we have a chain of three streams: 1) the stream of editable strings
          # (probably 1 to 3 for each graph document) 2) within each one, the
          # stream of comment lines and 3) of each comment line *maybe* a
          # meaning (so 3 is a reduction of 2). from the items produced by the
          # last stream we want to be able to reach the item that expand (1)
          # to (2) because it is a special stream subclass that gives us
          # metadata so we can mutate the strings in (1). this is never easy;
          # this is the third complete overhaul of how we do this.

          fly = Here_::Flyweight__.new

          special_line_st = nil

          Stream_[ @_string_array ].expand_by do |mutable_s|

            special_line_st = Models_::Comment::LineStream.of_mystery_string mutable_s

          end.map_reduce_by do | line |

            if ASSOCIATION_RX___ =~ line
              fly.set!(
                special_line_st.last_start_position,
                special_line_st.last_end_position,
                special_line_st.source_string )
              fly
            end
          end
      end

        ASSOCIATION_RX___ = /\A[ \t]*[-a-z]+[ \t]*:/

      # ==
    end
  end
end
Skylab::TanMan::Models_::Meaning::Collection_Controller__ = nil  # don't forget the `lazily` clause too
# #pending-rename: meanings operator branch facade
# #history-A: half full rewrite during ween off [br]-era
