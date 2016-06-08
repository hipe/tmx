module Skylab::TanMan

  class Models_::Meaning

    Actors_ = ::Module.new

    class Actors_::Apply

      Attributes_actor_.call( self,
        :meaning,
        :node,
        :meaning_stream,
        :dot_file,
      )

      def initialize & p
        @on_event_selectively = p
      end

      def execute

        @asmt_a = []  # flat list of asmt entry structs
        @index_h = {}  # hash of arrays of indexs into above
        @parser = @dot_file.graph_sexp.class.grammar.parser_for_rule :a_list  # :+[#054] #watch

        ok = resolve_string_array
        ok &&= process_each_string
        ok &&= check_for_conflict
        ok && update_the_attributes_of_the_node
      end

      def resolve_string_array
        @s_a = Models_::Meaning::Graph__.new(  # yes, [#076] graph is a one-off
          @meaning_stream
        ).meaning_values_via_meaning_name @meaning.natural_key_string, & @on_event_selectively
        @s_a and ACHIEVED_
      end

      def process_each_string
        ok = nil
        @s_a.each do | s |
          ok = parse_meaning_string s
          ok or break
          _a_list = @dot_file.graph_sexp.class.element2tree ok, :custom_a_list
          _a_list.to_item_array_.each do | a_list1 |
            ok = process_list_item a_list1, s
            ok or break
          end
          ok or break
        end
        ok
      end

      def parse_meaning_string s
        tree = @parser.parse s
        if ! tree
          tree = when_failed_to_parse_meaning_string s
        end
        tree
      end

      def when_failed_to_parse_meaning_string s

        @on_event_selectively.call :error, :failed_to_parse_meaning_string do

          Common_::Event.inline_not_OK_with :failed_to_parse_meaning_string,
              :input_string, s,
              :failure_reason, @parser.failure_reason do | y, o |

            y << "failed to parse #{ val o.input_string } - #{ o.failure_reason }"
          end
        end
      end

      def process_list_item a_list1, s

        o = Meaning_Ast_Entry__[ a_list1, s ]
        asmt_d = @asmt_a.length
        @asmt_a.push o

        id_s = o.a_list1.id.unparse
        existing_a = @index_h.fetch id_s do | _ |
          @index_h[ id_s ] = []
        end
        id_s = nil

        if existing_a.length.zero?
          existing_a.push asmt_d
        else
          otr = @asmt_a.fetch existing_a.last
          if otr.a_list1.equals.id.normalized_string != o.a_list1.equals.id.normalized_string

            # then a conflict in meaning - aggregate them all & report later

            existing_a.push asmt_d
          end
        end
        ACHIEVED_
      end

      Meaning_Ast_Entry__ = ::Struct.new :a_list1, :meaning

      # ~

      def check_for_conflict
        conflict_h = @index_h.select do | _, a |
          1 < a.length
        end

        if conflict_h.length.zero?
          ACHIEVED_
        else
          when_conflict confict_h
        end
      end

      def when_conflict conflict_h

        @on_event_selectively.call :error, :unresolvable_conflicts_in_meaning do

          Common_::Event.inline_not_OK_with :unresolvable_conflicts_in_meaning,
              :conflict_h, conflict_h,
              :asmt_a, @asmt_a do | y, o |

            _sp_a = o.conflict_h.map do |atr_s, d_a|

              _pred_a = d_a.map do | d |

                ast = o.asmt_a.fetch d

                "in #{ lbl ast.meaning.name } as #{
                  }#{ ick ast.a_list1.equals.id.normalized_string }"
              end

              "#{ ick atr_s } was defined #{ _pred_a * ' and ' } #{
                }- which one is right?"
            end

            y << "there are unresolvable conflicts in meaning - #{
              }#{ _sp_a.join '. ' }"

          end
        end

        UNABLE_
      end

      # ~

      def update_the_attributes_of_the_node
        @node.to_controller.update_attributes build_atrs
      end

      def build_atrs

        # since some assignments might be redundant, we do a subset

        _sorted_pairs = @index_h.map do | k, a |
          [ k, a.first ]
        end.sort do | a, b |
          a.last <=> b.last
        end

        _sorted_pairs.map do | atr, d |
          [ atr, @asmt_a.fetch( d ).a_list1.equals.id.normalized_string ]
        end
      end
    end
  end
end
