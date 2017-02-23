module Skylab::TanMan

  class Models_::Meaning

    class Collection_Controller__ <  Model_::DocumentEntity::Collection_Controller

      class << self

        def via_iambic x_a
          new do
            init_via_iambic x_a
          end
        end
      end  # >>

      include Common_Collection_Controller_Methods_

      # ~ create

      def persist_entity bx=nil, ent, & oes_p

        _has_force = if bx
          bx[ :force ]
        end

        _ok = Here_::Actors__::Persist.call(
          _build_session,
          _has_force,
          ent,
          & oes_p )

        _ok and begin
          flush_changed_document_to_ouptut_adapter  # no guarantee it did change but meh. :+[#001] where does saving happen?
        end
      end

      # ~ retrieve (many)

      def to_entity_stream_via_model cls, & oes_p

        if @model_class == cls  # just to punish those who dare defy us
          _build_session.to_stream_of_meanings_with_mutable_string_metadata
        end
      end

      # ~ custom business-specific

      def apply_meaning_to_node meaning, node
        Models_::Meaning::Actors_::Apply.call(
          meaning,
          node,
          _build_session.to_stream_of_meanings_with_mutable_string_metadata,
          document_,
          & @on_event_selectively )
      end

      # ~ support

      def _build_session
        Session__.new document_.graph_sexp
      end

      class Session__

        def initialize sx
          @s_a = []

          if ! sx.e6
            sx.e6 = ""  # MEH - make life easier by guaranteeing at least one editable
          end

          @fallback_mutable_string = sx.e6

          [ :e0, :e6, :e10 ].each do | sym |
            x = sx[ sym ]
            x and @s_a.push x
          end
        end

        attr_reader :fallback_mutable_string

        def to_stream_of_meanings_with_mutable_string_metadata

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

          Common_::Stream.via_nonsparse_array( @s_a ).expand_by do | mutable_s |

            special_line_st = Models_::Comment::Line_Stream.of_mystery_string mutable_s

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

      end
    end
  end
end
