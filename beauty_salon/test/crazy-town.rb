module Skylab::BeautySalon::TestSupport

  module Crazy_Town

    CommonInstanceMethods__ = ::Module.new

    ASSOCIATION_LYFE = ::Object.new

    def ASSOCIATION_LYFE.[] tcc
      tcc.extend ASSOCIATION_LYFE_ModuleMethods___
      tcc.include ASSOCIATION_LYFE_InstanceMethods___
    end

    module ASSOCIATION_LYFE_ModuleMethods___

      def given sym

        shared_subject :subject_association_ do
          build_association_ sym
        end

        define_method :given_symbol_ do
          sym
        end
      end
    end

    module ASSOCIATION_LYFE_InstanceMethods___

      def build_association_ sym
        subject_branch_.__child_association_via_symbol_and_offset_ sym, 1414
      end

      include CommonInstanceMethods__
    end

    module Structured_Nodes

      def self.[] tc
        tc.include self
      end

      # -- assert help

      def at_ m
        _sn = structured_node_
        _sn.send m
      end

      # -- build these things

      def structured_node_via_string_ s
        n = vendor_node_via_string_ s
        # (very wound-up for now)
        _magnetic = main_magnetics_::StructuredNode_via_Node
        _feature_branch = _magnetic.structured_nodes_as_feature_branch
        _class = _feature_branch.dereference n.type
        _class.via_node_ n
      end

      def vendor_node_via_string_ ruby_s
        _parser = Real_parser_for_current_ruby__[]
        _AST_node = _parser.parse ruby_s
        _AST_node  # hi.todo
      end

      # -- build parser AST nodes

      def build_parser_AST_node__ sym, * rest
        Build_vendor_parser_AST_node__[ sym, rest ]
      end

      define_method :parser_AST_node_builder_, -> do
        p = -> sym, * rest do
          Build_vendor_parser_AST_node__[ sym, rest ]
        end
        -> { p }
      end.call

      include CommonInstanceMethods__

      module THIS_ONE_MOCK ; class << self
        def tap_class
          NOTHING_
        end
        def receive_constituent_construction_services_ _
          NOTHING_
        end
      end ; end
    end

    # ==

    module PARSY_TOWN

      def self.[] tcc
        tcc.include self
      end

      def fails_with_these_normal_lines_ & p

        lines, x = _emission_lines_and_result_CT

        x == false || fail

        expect_these_lines_in_array_ lines, & p
      end

      def JUST_SHOW_ME_THE_LINES
        lines, _ = _emission_lines_and_result_CT
        io = debug_IO
        io.puts lines
        io.puts "GOODBYE FROM JUST_SHOW_ME_THE_LINES"
        exit 0
      end

      def _emission_lines_and_result_CT

        expecting_no_more_emissions = -> * do
          fail
        end

        lines = nil

        p = -> em_p, sym_a do

          lines = _lines_via_thing_CT em_p, sym_a

          p = expecting_no_more_emissions
        end

        _x = parsy_subject_magnetic_.call_by do |o|

          o.listener = -> * sym_a, & em_p do
            p[ em_p, sym_a ]
          end

          o.string = remove_instance_variable :@STRING
        end

        [ lines, _x ]
      end

      def expect_success_against_ string

        x = parsy_subject_magnetic_.call_by do |o|

          o.listener = -> * sym_a, & em_p do
            lines = _lines_via_thing_CT em_p, sym_a
            fail "unexpected etc startig with #{ lines[0].inspect }"
          end

          o.string = string
        end
        x || fail
        x
      end

      def _lines_via_thing_CT em_p, sym_a

        :error == sym_a.first || fail
        :expression == sym_a[1] || fail
        lines = []
        _p = if do_debug
          io = debug_IO
          -> line { io.puts line ; lines.push line }
        else
          -> line { lines.push line }
        end
        y = ::Enumerator::Yielder.new( & _p )
        _y_ = nil.instance_exec y, & em_p
        y.object_id == _y_.object_id || fail
        lines
      end
      # include CommonInstanceMethods__
    end

    # ==

    module Traversal

      def self.[] tc
        tc.include self
      end

      # -

        define_singleton_method :shared_subject, & TestSupport_::DANGEROUS_MEMOIZE

        def define_subject_magnetic_
          magnetic_for_traversal_.define do |o|
            yield o
          end
        end

        shared_subject :ast_node_of_addition_of_three_integers_ do
          s = parser_AST_node_builder_
          _left_term = s[ :zend, s[ :ind, 1 ], :+, s[ :ind, 2 ] ]
          s[ :zend, _left_term, :+, s[ :ind, 3 ] ]
        end

        shared_subject :feature_branch_for_traversal_one_ do

          _cls = build_subclass_with_these_children_( :My_send,
            :receiverosa_expression,
            :methodo_nameo_zymbol_terminal,
            :zero_or_more_argumentoso_expressions,
          )

          _cls2 = build_subclass_with_these_children_( :My_ind,
            :MY_INDEGER_indeger_terminal,
          )

          build_subject_branch_(
            _cls, :Zend,
            _cls2, :Ind,
            :ThisOneGuy,
          ) do
            self::TERMINAL_TYPE_SANITIZERS = {
              indeger: -> x do
                ::Integer === x
              end,
              zymbol: -> x do
                ::Symbol === x
              end,
            }
          end
        end

        def magnetic_for_traversal_
          main_magnetics_::Dispatcher_via_Hooks
        end
      # -
    end

    # ==

    module CommonInstanceMethods__

      def build_subclass_with_these_children_ c, * sym_a

        cls = ::Class.new subject_base_class_
        sandbox_module_.const_set c, cls
        cls.class_exec do
          children( * sym_a )
        end
        cls
      end

      def build_subject_branch_ *these, c, & p

        mod = ::Module.new
        sandbox_module_.const_set c, mod

        items_mod = if these.length.zero?
          :xx_hi_xx
        else
          ::Module.new
        end

        mod.const_set :Items, items_mod

        ( these.length / 2 ).times do |d|
          d <<= 1
          _cls = these.fetch d
          _c_ = these.fetch d+1

          items_mod.const_set _c_, _cls
        end

        if p
          mod.module_exec( & p )
        end

        Default_these_things[ mod ]

        feature_branch_magnetic_[ mod ]
      end

      def subject_base_class_
        feature_branch_magnetic_::GrammarSymbol
      end

      def feature_branch_magnetic_
        main_magnetics_::NodeProcessor_via_Module
      end

      alias_method :subject_magnetic_, :feature_branch_magnetic_
    end

    # ==

    Default_these_things = -> mod do

      if ! mod.const_defined? :IRREGULAR_NAMES, false
        mod.const_set :IRREGULAR_NAMES, nil
      end

      if ! mod.const_defined? :TERMINAL_TYPE_SANITIZERS, false
        mod.const_set :TERMINAL_TYPE_SANITIZERS, nil
      end
    end

    # ==

    Build_vendor_parser_AST_node__ = -> do
      once = -> do
        once = nil ; Real_parser_for_current_ruby__[] ; nil
      end
      -> sym, rest do
        once && once[]
        ::Parser::AST::Node.new sym, rest
      end
    end.call

    Real_parser_for_current_ruby__ = -> do
      Home_::CrazyTownReportMagnetics_::
          DocumentNodeStream_via_FilePathStream::
          For_now_always_the_same_ruby_parser_with_certain_settings___[]
    end

    # ==

    DoccyWrap = ::Struct.new :ast_

    # ==
    # ==
  end
end
# #born: broke out of a spec file
