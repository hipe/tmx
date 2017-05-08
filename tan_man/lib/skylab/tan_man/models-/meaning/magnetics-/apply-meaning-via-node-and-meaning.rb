module Skylab::TanMan

  module Models_::Meaning

    class Magnetics_::ApplyMeaning_via_Node_and_Meaning < Common_::MagneticBySimpleModel

      # (contemporary with the writing of this comment, we contempify only
      # those method names that we touch, and few if any of the ivars..)

      def initialize
        super
      end

      attr_writer(
        :is_dry,
        :listener,
        :meaning_name_string,
        :meanings_operator_branch,
        :mutable_digraph,
        :node_label,
      )

      def execute

        @_parsing_support = @mutable_digraph.graph_sexp.class
        @parser = @_parsing_support.grammar.parser_for_rule :a_list  # #[#054] #watch

        @asmt_a = []  # flat list of asmt entry structs
        @index_h = {}  # hash of arrays of indexs into above

        ok = true
        ok &&= __resolve_entities_via_strings
        ok &&= __resolve_string_array
        ok &&= process_each_string
        ok &&= check_for_conflict
        ok && update_the_attributes_of_the_node
      end

      # -- C

      def __resolve_string_array

        _normal_meaning_name = remove_instance_variable( :@meaning ).natural_key_string

        @meaning_stream = @meanings_operator_branch.to_meaning_entity_stream_  # (preserve below legacy for now..)

        _s_a = Models_::Meaning::Graph__.new(  # yes, [#076] graph is a one-off
          @meaning_stream
        ).meaning_values_via_meaning_name _normal_meaning_name, & @listener

        remove_instance_variable :@meaning_stream

        _store :@s_a, _s_a
      end

      # -- D

      def process_each_string
        ok = nil
        @s_a.each do | s |
          ok = parse_meaning_string s
          ok or break
          _a_list = @_parsing_support.tree_via_syntax_node_ ok, :custom_a_list
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

          Common_::Event.inline_not_OK_with(
            :failed_to_parse_meaning_string,
            :input_string, s,
            :failure_reason_string, @parser.failure_reason,  # (not our name)
          ) do |y,o|
            y << "failed to parse #{ val o.input_string } - #{ o.failure_reason_string }"
          end
        end

        UNABLE_
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
          if otr.a_list1.equals.id.normal_content_string_ != o.a_list1.equals.id.normal_content_string_

            # then a conflict in meaning - aggregate them all & report later

            existing_a.push asmt_d
          end
        end
        ACHIEVED_
      end

      Meaning_Ast_Entry__ = ::Struct.new :a_list1, :meaning

      # -- E

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
                  }#{ ick ast.a_list1.equals.id.normal_content_string_ }"
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

      # -- F

      def update_the_attributes_of_the_node

        _h = build_atrs

        _ok = Models_::Node::Magnetics_::UpdateAttributes_via_Hash_and_Node.call_by do |o|
          o.node = @node
          o.attributes_hash = _h
          o.listener = @listener
        end

        _ok && @node
      end

      def build_atrs

        # since some assignments might be redundant, we do a subset

        # (order the name-value pairs in the order of their first
        # appearance (in this attribute list) in the document.)

        _sorted_pairs = @index_h.map do | k, a |
          [ k, a.first ]
        end.sort do | a, b |
          a.last <=> b.last
        end

        h = {}
        _sorted_pairs.each do |name_s, d|

          _el = @asmt_a.fetch d
          _use_value_s = _el.a_list1.equals.id.normal_content_string_

          h[ name_s.intern ] = _use_value_s
        end
        h
      end

      # -- B

      def __resolve_entities_via_strings

        _ok = __resolve_node_via_node_label
        _ok && __resolve_meaning_via_meaning_name_string
      end

      def __resolve_meaning_via_meaning_name_string

        _meaning_head = remove_instance_variable :@meaning_name_string

        _meaning = @meanings_operator_branch.one_entity_against_natural_key_fuzzily_(
          _meaning_head, & @listener )

        _store :@meaning, _meaning
      end

      def __resolve_node_via_node_label

        _NODES_OB = Models_::Node::NodesOperatorBranchFacade_TM.new @mutable_digraph

        _node_label = remove_instance_variable :@node_label

        _node = _NODES_OB.one_entity_against_natural_key_fuzzily_(
          _node_label, & @listener )

        _store :@node, _node
      end

      # -- A

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_

      # ==
      # ==
    end
  end
end
