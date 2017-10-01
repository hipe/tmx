module Skylab::BeautySalon::TestSupport

  module Crazy_Town

    def self.[] tc
      tc.include self
    end

    module THIS_STUFF

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
        _magnetic = Home_::CrazyTownMagnetics_::SemanticTupling_via_Node
        _feature_branch = _magnetic.structured_nodes_as_feature_branch
        _class = _feature_branch.dereference n.type
        _class.via_node_ n
      end

      def vendor_node_via_string_ ruby_s
        _parser = Real_parser_for_current_ruby__[]
        _AST_node = _parser.parse ruby_s
        _AST_node  # hi.todo
      end

      # -- build these things

      define_method :builder_thing_, ( Lazy_.call do

        Real_parser_for_current_ruby__[]  # load 2 things

        -> sym, * rest do
          ::Parser::AST::Node.new sym, rest
        end
      end )

      # -- build these things

      def build_subject_branch_ *these, c, & p

        mod = ::Module.new
        sandbox_module_.const_set c, mod

        items_mod = ::Module.new
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

        if ! mod.const_defined? :IRREGULAR_NAMES, false
          mod.const_set :IRREGULAR_NAMES, nil
        end

        subject_magnetic_[ mod ]
      end

      def build_subclass_with_these_children_ c, * sym_a

        cls = ::Class.new subject_base_class_
        sandbox_module_.const_set c, cls
        cls.class_exec do
          children( * sym_a )
        end
        cls
      end

      def subject_base_class_
        subject_magnetic_::GrammarSymbol
      end

      def subject_magnetic_
        Home_::CrazyTownMagnetics_::NodeProcessor_via_Module
      end

      module THIS_ONE_MOCK ; class << self
        def tap_class
          NOTHING_
        end
        def __receive_constituent_construction_services_ _
          NOTHING_
        end
      end ; end
    end

    # -

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

        _x = subject_magnetic_.call_by do |o|

          o.listener = -> * sym_a, & em_p do
            p[ em_p, sym_a ]
          end

          o.string = remove_instance_variable :@STRING
        end

        [ lines, _x ]
      end

      def expect_success_against_ string

        x = subject_magnetic_.call_by do |o|

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

    # -

    Real_parser_for_current_ruby__ = -> do
      Home_::CrazyTownReportMagnetics_::
          DocumentNodeStream_via_FilePathStream::
          For_now_always_the_same_ruby_parser_with_certain_settings___[]
    end

    # ==
    # ==
  end
end
# #born: broke out of a spec file
