require_relative '../test-support'

module Skylab::TanMan::TestSupport::Sexp::Auto::Recursive_Rule

  ::Skylab::TanMan::TestSupport::Sexp::Auto[ TS_ = self ]

  include Constants

  extend TestSupport_::Quickie

  EMPTY_S_ = EMPTY_S_ ; TanMan_ = TanMan_ ; TestLib_ = TestLib_

  module ModuleMethods

    def give_stmt_list_a_prototype

      alias_method :_stmt_list, :stmt_list
      let :stmt_list do           # egads we duplicate a hack that occurs elsew.
        _stmt_list # kick
        sl = graph_sexp.class.parse :stmt_list, "xyzzy_1\nxyzzy_2"
        if ! graph_sexp[:stmt_list]
          graph_sexp[:stmt_list] = sl.__dupe except: [:stmt, :tail]
        end
        if ! graph_sexp.stmt_list._prototype
          graph_sexp.stmt_list._prototype = sl
        end
        graph_sexp.stmt_list
      end
    end

    def with string
      define_method :with_string do
        string
      end
    end
  end

  module InstanceMethods
    attr_reader :actual_string

    def expect expected_string
      actual_string.should eql( expected_string )
    end

    attr_reader :graph_sexp
  end

  module Attr_List_I_M

    def go asst_to_insert_string
      gs = graph_sexp
      if EMPTY_S_ == with_string  # hack an empty alist..
        a_list = gs.class.parse :a_list, 'e=f'
        a_list[:content] = nil  # toss a perfectly good AList1
      else
        a_list = gs.class.parse :a_list, with_string
      end
      a_list._prototype = gs.class.parse :a_list, 'a=b, c=d'
      new_before_this = New_before_this__[ a_list, asst_to_insert_string ]
      a_list._insert_item_before_item asst_to_insert_string, new_before_this
      @actual_string = a_list.unparse
      nil
    end

    define_method :graph_sexp, -> do
      _GRAPH_SEXP_ = nil
      -> do
        _GRAPH_SEXP_ ||= build_graph_sexp_once
      end
    end.call

    def build_graph_sexp_once

      TanMan_::Models_::DotFile.produce_parse_tree_via(
        handle_event_selectively
      ) do | o |
        o.input_string 'digraph{}'
        o.generated_grammar_dir_path existent_testing_GGD_path
      end
    end
  end

  module Stmt_List_I_M

    TestLib_::Let[ self ]

    include Constants

    def go node_to_insert_string
      new_before_this = New_before_this__[ stmt_list, node_to_insert_string ]
      stmt_list._insert_item_before_item node_to_insert_string, new_before_this
      @actual_string = stmt_list.unparse
      nil
    end

    def stmt_list
      @did_resolve_stmt_list ||= resolve_stmt_list
      @stmt_list
    end

    def resolve_stmt_list

      @graph_sexp = TanMan_::Models_::DotFile.produce_parse_tree_via(
        handle_event_selectively
      )  do | o |
        o.input_string "digraph{#{ with_string }}"
        o.generated_grammar_dir_path existent_testing_GGD_path
      end

      @stmt_list = @graph_sexp.stmt_list
      true
    end
  end

  New_before_this__ = -> recursive_list, string do
    # [#071] repeated here just because it's easy and we want independence
    recursive_list._items.detect do |item|
      -1 == ( string <=> item.unparse )
    end
  end

end
