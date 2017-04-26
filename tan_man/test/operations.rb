module Skylab::TanMan::TestSupport

  module Operations

    def self.[] tcc
      tcc.include self
    end

    if false

    # ~ adjunct facet : hearing ( & abstract graphs )

    def add_association_to_abstract_graph lbl_src_s, lbl_dst_s
      @__abstract_graph ||= []
      @__abstract_graph.push [ :__asc__, lbl_src_s, lbl_dst_s ]
      nil
    end

    def add_nodes_to_abstract_graph * s_a
      @__abstract_graph ||= []
      s_a.each do | lbl_s |
        @__abstract_graph.push [ :__nds__, s_a ]
      end
      nil
    end

    def begin_empty_abstract_graph
      @__abstract_graph = [] ; nil
    end

    def hear_words s_a

      @input_s = __input_string_via_abstract_graph
      @output_s = ""

      call_API :hear,
        :word, s_a,
        :input_string, @input_s,
        :output_string, @output_s

      nil
    end

    def __input_string_via_abstract_graph

      line_a = [ 'digraph {' ]
      seen_lbl_h = {}
      @__seen_id_h = {}
      lbl_to_id_h = {}

      @__abstract_graph.each do | record |

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
    end  # if false

    # -- expectations (assertions)

    def expect_these_lines_in_array_with_trailing_newlines_ act_s_a, & p

      TestSupport_::Expect_Line::
        Expect_these_lines_in_array_with_trailing_newlines[ act_s_a, p, self ]

      NIL
    end

    # -- TMPDIR TOWN

    def given_dotfile_ content_s

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
  end
end
