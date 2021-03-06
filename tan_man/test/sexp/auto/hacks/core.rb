module Skylab::TanMan::TestSupport

  module Sexp::Auto::Hacks

    def self.[] tcc
      Sexp::Auto[ tcc ]
      tcc.extend Module_Methods___
      tcc.include Instance_Methods___
    end
    # <-

  module Module_Methods___

    def use_statement_list_instance_methods__
      include Statement_List_Instance_Methods___
    end

    def use_attr_list_instance_methods__
      include Attr_List_Instance_Methods___
    end

    def add_separating_prototype_to_stmt_list

      define_method :_prototype_for_front_stmt_list do
        Memoized_SL_proto___[] || Memoize_SL_proto___[ @graph_sexp.class ]
      end
    end
  end

  -> do

    p = nil

    Memoized_SL_proto___ = -> do
      if p
        p[]
      end
    end

    Memoize_SL_proto___ = -> o do

      x = o.parse :stmt_list, "xyzzy_1\nxyzzy_2"
      p = -> do
        x
      end
      x
    end

  end.call

  module Attr_List_Instance_Methods___

    def insrt asst_to_insert_s

      s = input_string
      if s.length.zero?  # then hack an empty alist ..
        a_list = _parser.parse :a_list, 'e=f'
        a_list[ :content ] = nil  # toss a perfectly good AList1
      else
        a_list = _parser.parse :a_list, s
      end

      a_list.prototype_ = Memoized_A_list_prototype___[] || Memoize_A_list_prototype___[ _parser ]

      new_before_this_item = Find_new_before_this_item__[ a_list, asst_to_insert_s, :content ]

      if new_before_this_item
        a_list.insert_item_before_item_ asst_to_insert_s, new_before_this_item
      else
        a_list.append_item_via_string_ asst_to_insert_s
      end

      @a_list_s = a_list.unparse
      nil
    end

    def _parser

      # hack parsing an empty digraph (once per runtime) just to get the parser :/

      Memoized_parser__[] || Memoize_parser__[ _resolve_graph_sexp.nil? && @graph_sexp.class ]

    end

    def produce_digraph_input_string_
      "digraph{}"
    end
  end

  -> do
    x = nil
    Memoized_parser__ = -> do
      x
    end
    Memoize_parser__ = -> x_ do
      x = x_
    end
  end.call

  -> do
    p = nil
    Memoized_A_list_prototype___ = -> do
      if p
        p[]
      end
    end
    Memoize_A_list_prototype___ = -> o do
      x = o.parse :a_list, 'a=b, c=d'
      p = -> do
        x
      end
      x
    end
  end.call

  module Statement_List_Instance_Methods___

    def insrt node_to_insert_s

      __resolve_graph_sexp_and_stmt_list

      x = @stmt_list

      new_before_this_node = Find_new_before_this_item__[ x, node_to_insert_s, :stmt ]

      if new_before_this_node
        x.insert_item_before_item_(
          node_to_insert_s, new_before_this_node )
      else
        x.append_item_via_string_ node_to_insert_s
      end

      @stmt_list_s = x.unparse

      nil
    end

    def produce_digraph_input_string_
      "digraph{#{ input_string }}"
    end

    def __resolve_graph_sexp_and_stmt_list

      _resolve_graph_sexp

      @stmt_list = @graph_sexp.stmt_list

      x = _prototype_for_front_stmt_list
      if x
        if ! @stmt_list

          # :+#artificial starter - this logic is duplicated elsewhere :/

          x_ = x.dup
          x_[ :stmt ] = nil
          x_[ :tail ] = x_[ :tail ].dup
          x_[ :tail ][ :stmt_list ] = nil
          @graph_sexp.stmt_list = x_
          @stmt_list = x_
        end

        @stmt_list.prototype_ = x
      end

      nil
    end

    def _prototype_for_front_stmt_list
    end
  end

  module Instance_Methods___

    def _resolve_graph_sexp

      @graph_sexp = Home_::Models_::DotFile::
          ParseTree_via_ByteUpstreamReference.via(

        :byte_upstream_reference,
          Byte_upstream_reference_[].via_string(
            produce_digraph_input_string_ ),

        :generated_grammar_dir_path, existent_testing_GGD_path,

        & event_log.listener )

      nil
    end

    def subject
      Home_::Sexp_::Auto::Hacks__::RecursiveRule
    end
  end

  Find_new_before_this_item__ = -> recursive_list, string, k do  # (was once same as [#071])

    node = recursive_list.to_element_stream_.to_enum.detect do | node_ |

      if node_[ k ]  # else might be an artificial empty starter stub
        -1 == ( string <=> node_[ k ].unparse )
      end
    end

    if node
      node[ k ]
    end
  end
# ->
  end
end
