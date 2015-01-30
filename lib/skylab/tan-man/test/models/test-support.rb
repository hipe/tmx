require_relative '../test-support'

module Skylab::TanMan::TestSupport::Models

  ::Skylab::TanMan::TestSupport[ TS_ = self ]

  include Constants

  extend TestSupport_::Quickie

  EMPTY_S_ = EMPTY_S_

  NEWLINE_ = NEWLINE_

  TanMan_ = TanMan_ ; TestLib_ = TestLib_

  Brazen_ = TanMan_::Brazen_

  Callback_ = TanMan_::Callback_

  module Constants

    Within_silo = -> silo_name_i, instance_methods_module do
      _NODE_ID_ = Brazen_.node_identifier.via_symbol silo_name_i
      instance_methods_module.send :define_method, :silo_node_identifier do
        _NODE_ID_
      end  ; nil
    end
  end

  module InstanceMethods

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

        trios = lbl_s_a.map do | lbl_s |
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

        trios.each do | lbl_s, id_s, have_seen |

          if ! have_seen
            line_a.push "  #{ id_s } [ label=\"#{ lbl_s }\" ]"
          end
        end

        if is_assoc
          line_a.push "  #{ trios.first[ 1 ] } -> #{ trios.last[ 1 ] }"
        end
      end
      line_a.push "}\n"
      line_a.join "\n"
    end

    def __generate_unique_id_for_label lbl_s
      s_a = lbl_s.split TanMan_::SPACE_
      s_a_ = s_a[ 0, 1 ]
      len = s_a.length
      d = 1
      while @__seen_id_h[ s_a_ ] and d < len
        s_a_.push s_a.fetch d
        d += 1
      end
      @__seen_id_h[ s_a_ ] = true
      s_a_ * TanMan_::Brazen_::UNDERSCORE_
    end

    # ~

    def build_event_receiver_for_expect_event
      evr = super
      evr.add_event_pass_filter do |ev|
        :using != ev.terminal_channel_i
      end
      evr
    end

    def collection_controller
      @collection_controller ||= b_c_c
    end

    def b_c_c
      silo
      _id = @silo.model_class.node_identifier

      oes_p = handle_event_selectively

      k = kernel

      _inp_a = send :"bld_input_args_when_#{ input_mechanism_i }"

      @action = Mock_Action__.new _inp_a, k, & oes_p

      _g = Brazen_::Model_::Preconditions_::Graph.new @action, k, & oes_p

      @silo.provide_collection_controller_prcn _id, _g, & oes_p
    end

    def bld_input_args_when_input_file_granule
      [ Brazen_.model.actual_property.new( input_file_pathname.to_path, :input_path ) ]
    end

    def silo_controller
      @silo_controller ||= b_s_c
    end

    def silo
      @silo ||= b_s
    end

    def b_s
      kernel.silo_via_identifier silo_node_identifier
    end

    def kernel
      subject_API.application_kernel
    end

    # ~ fixture and prepared dir and file paths

    def using_dotfile content_s

      prepare_ws_tmpdir

      @workspace_path = @ws_pn.to_path  # push up as needed

      ::File.open( dotfile_path, W_ ) do | fh |
        fh.write content_s
      end

      ::File.open( File.join( @workspace_path, cfn_shallow ), W_ ) do | fh |
        fh.write "[ graph \"#{ THE_DOTFILE__ }\" ]\n"
      end

      nil
    end

    def dotfile_path
      ::File.join @workspace_path, THE_DOTFILE__
    end

    def use_empty_ws
      td = verbosify_tmpdir empty_dir_pn
      if Do_prepare_empty_tmpdir__[]
        td.prepare
      end
      @ws_pn = td ; nil
    end

    Do_prepare_empty_tmpdir__ = -> do
      p = -> do
        p = NILADIC_EMPTINESS_
        true
      end
      -> { p[] }
    end.call

    NILADIC_EMPTINESS_ = -> { }

    def empty_dir_pn
      TestLib_::Empty_dir_pn[]
    end

    def empty_work_dir
      @empty_work_dir ||= begin
        prepare_ws_tmpdir
        @ws_pn.to_path
      end
    end

    def prepare_ws_tmpdir s=nil
      td = verbosify_tmpdir volatile_tmpdir
      td.prepare
      if s
        td.patch s
      end
      @ws_pn = td ; nil
    end

    def volatile_tmpdir
      TestLib_::Volatile_tmpdir[]
    end

    def verbosify_tmpdir td
      if do_debug
        if ! td.be_verbose
          td = td.new_with :be_verbose, true, :debug_IO, debug_IO
        end
      elsif td.be_verbose
        self._IT_WILL_BE_EASY
      end
      td
    end

    def dir sym
      ::File.join( dirs,
        sym.id2name.gsub( Callback_::UNDERSCORE_, Callback_::DASH_ ) )
    end

    def dirs
      ::Skylab::TanMan::TestSupport::Fixtures::Dirs.dir_pathname.to_path
    end

    def cfn
      CONFIG_FILENAME___
    end
    CONFIG_FILENAME___ = 'local-conf.d/config'.freeze

    def cfn_shallow
      CONFIG_FILENAME_SHALLOW___
    end
    CONFIG_FILENAME_SHALLOW___ = 'tern-mern.conf'
  end

  class Mock_Action__

    def initialize inp_a, k, & oes_p
      @input_arguments = inp_a
      @kernel = k
      @oes_p = oes_p
    end

    def controller_nucleus  # #experiment in [br]
      [ @kernel, @oes_p ]
    end

    attr_reader :input_arguments
  end

  THE_DOTFILE__ = 'the.dot'

  W_ = 'w'  # track its use
end
