module Skylab::TanMan::TestSupport

  module Operations

    def self.[] tcc

      tcc.send :define_singleton_method, :ignore_these_events,
        DEFINITION_FOR_THE_METHOD_CALLED_IGNORE_THESE_EVENTS___

      tcc.include self
    end

    # -
      DEFINITION_FOR_THE_METHOD_CALLED_IGNORE_THESE_EVENTS___ = -> * syms do
        h = {}
        syms.each do |sym|
          h[ sym ] = true
        end
        h.freeze
        define_method :ignore_emissions_whose_terminal_channel_is_in_this_hash do
          h
        end
        NIL
      end
    # -

    module Legacy_Methods_For_Hear

      # NOTE this module is something of a mishmash that exists *wholly*
      # because we want to see (experimentally) what hoops we have to jump
      # through to keep as much as possible the legacy code intact of a
      # particular few test(s). because the methods in this category run the
      # gamut from behavior we might want to re-use across silos to behavior
      # specific to one silo ("hear"), they are for now all in this file.

      def self.[] tcc

        Legacy_Methods_For_Emission[ tcc ]

        tcc.send :define_singleton_method,
          :ignore_these_events, DEFINITION_FOR_THE_METHOD_CALLED_IGNORE_THESE_EVENTS___

        tcc.include Operations
        tcc.include self
      end

      # -- assertion & conceptually related

      def build_scanner_via_output_string_

        tup = tuple_
        sct = tup.writey_struct
        sct.did_write || fail
        # sct.user_value.HELLO_ENTITY  assumes did below
        _big_s = tup.__output_string_
        TestSupport_::Expect_Line::Scanner.via_string _big_s
      end

      def expect_did_not_write__
        tuple_.writey_struct.did_write && fail
      end

      def expect_did_write_
        tuple_.writey_struct.did_write || fail
      end

      # -- setup

      def expect_succeed
        sct = execute
        sct.did_write  # assert responds to
        sct.user_value.HELLO_ENTITY
        _s = remove_instance_variable :@OUTPUT_STRING
        MyTuple___[ _s, sct ]
      end

    def add_association_to_abstract_graph lbl_src_s, lbl_dst_s
        _abstract_graph_OPER.push [ :__asc__, lbl_src_s, lbl_dst_s ]
        NIL
    end

    def add_nodes_to_abstract_graph * s_a
        a = _abstract_graph_OPER
        s_a.each do |lbl_s|
          a.push [ :__nds__, s_a ]
        end
        NIL
    end

    def begin_empty_abstract_graph
        _abstract_graph_OPER
        NIL
    end

      def _abstract_graph_OPER
        @ABSTRACT_GRAPH ||= []
      end

      # ~ setup the API call

    def hear_words s_a

        s = ""
        _big_s = __input_string_via_abstract_graph

        call_API(
          * the_subject_action_for_hear_,
          :words, s_a,
          :input_string, _big_s,
          :output_string, s,
        )

        @OUTPUT_STRING = s ; nil
    end

      # ~ mixed support

    def __input_string_via_abstract_graph

      line_a = [ 'digraph {' ]
      seen_lbl_h = {}
      @__seen_id_h = {}
      lbl_to_id_h = {}

        _ag = remove_instance_variable :@ABSTRACT_GRAPH
        _ag.each do |record|

        if :__asc__ == record.first
          is_assoc = true
          lbl_s_a = record[ 1 .. 2 ]
        else
          is_assoc = false
          lbl_s_a = record.fetch 1
        end

        qkn_a = lbl_s_a.map do | lbl_s |
          id_s = nil
          have_seen = seen_lbl_h.fetch lbl_s do
            seen_lbl_h[ lbl_s ] = true
            id_s = __generate_unique_id_for_label lbl_s
            lbl_to_id_h[ lbl_s ] = id_s
            false
          end
          if have_seen
            id_s = lbl_to_id_h.fetch lbl_s
          end
          [ lbl_s, id_s, have_seen ]
        end

        qkn_a.each do | lbl_s, id_s, have_seen |

          if ! have_seen
            line_a.push "  #{ id_s } [ label=\"#{ lbl_s }\" ]"
          end
        end

        if is_assoc
          line_a.push "  #{ qkn_a.first[ 1 ] } -> #{ qkn_a.last[ 1 ] }"
        end
        end

      line_a.push "}\n"
      line_a.join "\n"
    end

    def __generate_unique_id_for_label lbl_s
      s_a = lbl_s.split SPACE_
      s_a_ = s_a[ 0, 1 ]
      len = s_a.length
      d = 1
      while @__seen_id_h[ s_a_ ] and d < len
        s_a_.push s_a.fetch d
        d += 1
      end
      @__seen_id_h[ s_a_ ] = true
      s_a_ * UNDERSCORE_
    end
    end  # legacy methods

    MyTuple___ = ::Struct.new :__output_string_, :writey_struct

    # ==

    Legacy_Methods_For_Emission = -> tcc do
      tcc.send :define_method, :expect_OK_event,
        DEFINITION_FOR_THE_METHOD_CALLED_EXPECT_OK_EVENT___
      NIL
    end

    # -
      DEFINITION_FOR_THE_METHOD_CALLED_EXPECT_OK_EVENT___ = -> term_chan_sym do
        expect :info, term_chan_sym
        # (these emissions should generally be structured events whose members
        # and expression we have already tested in previous test files)
        NIL
      end
    # -

    # ==

    # -- expectations (assertions)

    def string_of_excerpted_lines_of_output_ r

      # #history-A.1: in its original form this existed as a method called
      # `excerpt` that was sunsetted near the time we *started* re-covering
      # the operations.

      _lines = __excerpted_lines_of_output_OPER r
      _lines.join EMPTY_S_  # the lines are newline *terminated*
    end

    def __excerpted_lines_of_output_OPER r

      if respond_to? :_tuple
        _tuple_a = _tuple
        _output_s = _tuple_a.first
      else
        _output_s = tuple_.output_string
      end

      _lines = _output_s.split %r(^)  # LINE_SPLITTING_RX_
      _lines[ r ]
    end

    def expect_these_lines_in_array_with_trailing_newlines_ act_s_a, & p

      TestSupport_::Expect_Line::
        Expect_these_lines_in_array_with_trailing_newlines[ act_s_a, p, self ]

      NIL
    end

    # -- TMPDIR TOWN

    def given_dotfile__ content_s  # (was: `given_dotfile_`)

      td = volatile_tmpdir

      td.prepare

      workspace_path = td.path

      dotfile_path = ::File.join workspace_path, THE_DOTFILE__

      mode = ::File::WRONLY | ::File::CREAT

      ::File.open dotfile_path, mode do |fh|
        fh.write content_s
      end

      cfn_filename = cfn_shallow

      _conf_path = ::File.join workspace_path, cfn_filename

      ::File.open _conf_path, mode do |fh|
        fh.puts "[ digraph ]"
        fh.puts "path = \"#{ THE_DOTFILE__ }\""
      end

      ThesePaths___.new dotfile_path, workspace_path, cfn_filename
    end

    def given_dotfile_FAKE_ workspace_path
      ThesePaths___.new ::File.join( workspace_path, THE_DOTFILE__ ), workspace_path, cfn_shallow
    end

    ThesePaths___ = ::Struct.new :dotfile_path, :workspace_path, :config_filename

    THE_DOTFILE__ = 'the.dot'

    def make_a_copy_of_this_workspace_ tail

      # use `cp -r` (similar) to copy the contents of a fixture tree into a
      # tmpdir, for use in a mutating operation on that "workspace".

      _path = path_for_fixture_workspace_ tail
      _use_path = ::File.join _path, '.'  # DOT_

      td = volatile_tmpdir
      td.prepare
      dst = td.path

      ::FileUtils.cp_r _use_path, dst
        # (we cheat and know that f.u is loaded by tmpdir above.)
        # (result is nil.)

      dst
    end

    def prepare_a_tmpdir_like_so_ patch_string

      td = volatile_tmpdir
      td.prepare
      _ok = td.patch patch_string
      _ok || TS_._SANITY
      td.path  # until you really need the controller (but why would you?)
    end

    def volatile_tmpdir
      _this_memoized_tmpdir_OPER :__build_volatile_tmpdir_OPER
    end

    def __build_volatile_tmpdir_OPER

      base_td = _this_memoized_tmpdir_OPER :__build_base_tmpdir_OPER

      _d = base_td.max_mkdirs + 1

      _vola_td = base_td.tmpdir_via_join 'volatile-tmpdir', :max_mkdirs, _d

      _vola_td  # hi. #todo
    end

    -> do

      # these particular tmpdir controllers are cached. the debugging
      # level of the controller is upgraded but is never downgraded.

      h = nil
      define_method :_this_memoized_tmpdir_OPER do |m|
        h ||= {}
        td = h.fetch m do
          x = send m
          h[ m ] = x
          x
        end
        if do_debug && ! td.be_verbose
          td = td.new_with(
            :be_verbose, true,
            :debug_IO, debug_IO,
          )
          h[ m ] = td
        end
        td
      end
    end.call

    def __build_base_tmpdir_OPER
      if do_debug
        yes = true ; io = debug_IO
      end
      _ = Home_.lib_.system_lib::Filesystem::Tmpdir.with(
        :path, TS_.tmpdir_path_,
        :be_verbose, yes,
        :debug_IO, io,
        :max_mkdirs, 1,
      )
      _  # hi. #todo
    end

    # --

    def fixture_file_ tail
      _head = fixtures_path_  # varies from node to node..
      ::File.join _head, tail
    end

    def path_for_workspace_005_with_just_a_config_
      path_for_fixture_workspace_ '005-just-a-config'
    end

    def path_for_fixture_workspace_ tail
      _head = dirs
      ::File.join _head, tail
    end

    def the_no_ent_directory_
      TestSupport_::Fixtures.directory :not_here
    end

    def the_empty_esque_directory_
      TestSupport_::Fixtures.directory :empty_esque_directory
    end

    def dir sym
      _head = dirs
      _tail = sym.id2name.gsub UNDERSCORE_, DASH_
      ::File.join _head, _tail
    end

    def dirs
      TS_::FixtureDirectories.dir_path
    end

    def cfn
      CONFIG_FILENAME___
    end
    CONFIG_FILENAME___ = 'local-conf.d/tm-conferg.file'.freeze

    def cfn_shallow
      'tern-mern.conf'
    end

    # ==
    # ==
  end
end
# :#history-A.1 (as referenced)
