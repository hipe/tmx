module Skylab::TMX::TestSupport

  module Operations::Map

    def self.[] tcc
      TS_::Memoizer_Methods[ tcc ]
      Operations[ tcc ]
      tcc.send :define_singleton_method, :ordered_items_by, DEFINITION_FOR_ORDERED_ITEMS_BY___
      tcc.include self
    end

    module Dir02

      def self.[] tcc
        tcc.include self
      end

      # -
        def full_valid_json_file_stream_
          _glob = ::File.join entities_dir_path_, Home_::GLOB_STAR_, 'valid.json'
          _files = ::Dir.glob _glob
          Stream_[ _files ]
        end

        def entities_dir_path_
          _mod = fixture_module_
          _path = _mod.dir_path
          ::File.join _path, 'entities'
        end

        def attributes_module_by_
          [ :attributes_module_by, -> { fixture_module_::Attriboots } ]
        end

        def fixture_module_
          TS_::FixtureDirectories::Dir_02_WithAttributes
        end
      # -
    end

    # -
      DEFINITION_FOR_ORDERED_ITEMS_BY___ = -> & p do

        call_by( & p )

        shared_subject :presumably_ordered_items_ do
          _pray = send_subject_call
          _pray.to_a
        end
      end
    # -

    # -

      # -- assertions

      def want_these_ * s_a
        ExpectThese___.new( s_a, self ).execute
      end

      def order_is_ * exp_s_a

        _nodes = presumably_ordered_items_
        act = []
        _nodes.each do |node|
          act.push node.get_filesystem_directory_entry_string
        end
        if act != exp_s_a
          expect( act ).to eql exp_s_a
        end
      end

      # ~ assertion support

      def last_item_
        presumably_ordered_items_.fetch( -1 )
      end

      # -- execution under test runtime

      def oldschool_jimmy_
        OldschoolJimmy___.instance
      end

      # -- setup

      def json_file_stream_01_

        # intentionally in dis-lexical order

        Dir01::JSON_file_stream_via[ %w( zagnut frim_frum ) ]
      end

      def json_file_stream_GA_

        # (to be "random", the below are in alphabetical order when each
        # word is read from back to front)

        Dir01::JSON_file_stream_via.call %w(
          deka
          dora
          guld
          damud
          goah
          adder
          stern
          tyris
          gilius
          trix
        )
      end

      def json_file_stream_ * s_a
        Dir01::JSON_file_stream_via[ s_a ]
      end

      def json_file_stream_via_ * s_a
        Dir01::JSON_file_stream_via[ s_a ]
      end

      def real_attributes_
        REAL_ATTRIBUTES___
      end

      REAL_ATTRIBUTES___ = [ :attributes_module_by, -> { Home_::Attributes_ } ]

    # -

    module Dir01

      def self.[] s
        Dir_01_path_lookup_function__[][ s ]
      end

      JSON_file_stream_via = -> s_a do
        Stream_.call s_a, & Dir_01_path_lookup_function__[]
      end
    end

    # ==

    fixture_dirs = nil

    Dir_01_path_lookup_function__ = Lazy_.call do

      # yes, to achieve more or less this same structure we could just glob
      # against the real filesystem rather than writing it by hand here, but
      # A) this way we can add entries for files that don't exist for testing
      # that, B) when using this structure it becomes explicit that we are
      # dictating the order these stream in and C) this way is less overhead

      h = {}

      dir = ::File.join fixture_dirs[], '01-fake-top-of-the-universe'

      same = "this.json"

      o = -> mid, tail=same do
        h[ mid ] = ::File.join dir, mid, tail
      end

      o[ "adder" ]   # 1 f 33
      o[ "damud" ]   # 2 f 44
      o[ "deka" ]    # 3 f 44
      o[ "dora" ]    # 4 s 3
      o[ "gilius" ]  # 5 s 4
      o[ "goah" ]    # 6 s 7
      o[ "guld" ]    # 7 s 7
      o[ "stern" ]   # 8 t 333
      o[ "trix" ]    # 9 t 333
      o[ "frim_frum", "any-name.json" ]
      o[ "tyris" ]   # 10 t 444
      o[ "zagnut", "any-other-name.json" ]

      -> s do
        h.fetch s
      end
    end

    # ==

    fixture_dirs = Lazy_.call do
      ::File.join TS_.dir_path, 'fixture-directories'
    end

    # ==

    class ExpectThese___

      def initialize s_a, tc
        @want_string_array = s_a
        @test_context = tc
      end

      def execute

        tc = @test_context

        exp_scn = Common_::Scanner.via_array @want_string_array
        tc.ignore_common_post_operation_emissions_
        _st = tc.send_subject_call

        actual_st = _st.map_by do |node|
          node.get_filesystem_directory_entry_string
        end

        begin
          actual_s = actual_st.gets
          if ! actual_s
            if exp_scn.no_unparsed_exists
              break  # win
            end
            fail __say_expected exp_scn.head_as_is
          end
          if exp_scn.no_unparsed_exists
            fail __say_extra actual_s
          end
          if actual_s == exp_scn.head_as_is
            exp_scn.advance_one
            redo
          end
          fail __say_not_the_same( actual_s, exp_scn.head_as_is )
        end while above
        NIL
      end

      def __say_not_the_same act_s, exp_s
        "expected #{ exp_s.inspect }, had #{ act_s.inspect }"
      end

      def __say_extra act_s
        "unexpected extra item: #{ act_s.inspect }"
      end

      def __say_expected exp_s
        "at end of page, expected #{ exp_s.inspect }"
      end

      def fail s
        @test_context.send :fail, s  # meh
      end
    end

    # ==

    class OldschoolJimmy___

      class << self
        def instance
          @___instance ||= new
        end
        private :new
      end  # >>

      alias_method :calculate, :instance_exec

      def par x
        if x.respond_to? :name_symbol
          x.name_symbol.inspect
        else
          ":#{ x.id2name }"  # hi.
        end
      end

      def ick x
        x.inspect
      end
    end

    # ==
  end
end
