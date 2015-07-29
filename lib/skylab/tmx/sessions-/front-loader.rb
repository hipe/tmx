module Skylab::TMX

  Sessions_ = ::Module.new
  class Sessions_::Front_Loader  # notes are in [#002]

    attr_writer(
      :bin_path,
      :filesystem,
      :number_of_synopsis_lines,
      :program_name_string_array,
      :tmx_host_mod,
    )

    def execute

      p = -> do
        p = -> do
          p = EMPTY_P_
          __build_second_level_stream
        end
        __build_first_level_stream
      end

      _st = Callback_.stream do
        p[]
      end

      _st.expand_by do | st |  # flatten a stream of streams into a stream
        st
      end
    end

    EMPTY_P_ = -> { }

    def __build_first_level_stream

      proto = Models_::Sidesystem_Module_Adapter.new(
        @program_name_string_array,
        __build_helpscreen_reducer_for_sidesystem,
      )

      seen = {}
      @_seen_in_first_level = seen  # will be used in second pass

      Home_.lib_.slicer.new_traversal.to_sidesystem_stream.map_reduce_by do | ss |

        if ss.mod::CLI
          nm = Callback_::Name.via_module ss.mod
          seen[ nm.as_slug ] = true
          proto.new nm, ss.mod
        end
      end
    end

    def __build_second_level_stream

      _all = @filesystem.glob ::File.join( @bin_path, '*' )
      proto = Models_::Script_Adapter.new(
        @program_name_string_array,
        __build_helpscreen_reducer_for_script,
      )

      # (using glob and not `entries` saves us from skipping '.' and '..')

      rsx = ::Regexp.escape ::File::SEPARATOR

      rx = /#{ rsx } tmx- (?<slug>  (?: (?!#{ rsx }) . )+  )  \z/x

        # (the "tmx-" in above should be a variable)

      seen = @_seen_in_first_level

      Callback_::Stream.via_nonsparse_array( _all ).map_reduce_by do | entry |

        md = rx.match entry
        if md
          if ! seen[ md[ :slug ] ]
            proto.new md, entry
          end
        end
      end
    end

    def __build_helpscreen_reducer_for_sidesystem

      o = _begin_reducer
      o.proxy_class = Enumerator_Yielder_Proxy___
      o
    end

    def __build_helpscreen_reducer_for_script

      o = _begin_reducer

      o.match_the_following_section_names_in_a_case_insensitive_manner

      o.use_section_in_descending_order_of_preference(
        :synopsis, :description, :usage )

      o.proxy_class = LTLT_and_Puts_Proxy___

      o
    end

    def _begin_reducer

      o = Home_::Modalities::CLI::Input_Adapters::Help_Screen.new

      o.number_of_lines = @number_of_synopsis_lines
      o.skip_blanks
      o.unstylize
      o
    end

    class Same__

      def initialize pn_s_a, reducer
        @program_name_string_array = pn_s_a
        @reducer_ = reducer
      end

      def name_value_for_order
        @name_.as_lowercase_with_underscores_symbol
      end

      def after_name_value_for_order
        NIL_
      end

      def is_visible
        true
      end

      def has_description
        true
      end
    end

    Models_ = ::Module.new
    class Models_::Sidesystem_Module_Adapter < Same__  # akin to "action adapter", etc

      def new nm, mod
        otr = dup
        otr.__init nm, mod
        otr
      end

      def __init nm, mod
        @mod = mod
        @name_ = nm
        NIL_
      end

      def under_expression_agent_get_N_desc_lines expag, number_of_lines

        number_of_lines == @reducer_.number_of_lines or self._SANITY

        @reducer_.lines_by do | line_yielder |
          @mod.describe_into_under line_yielder, expag
        end
      end

      def name
        @name_
      end
    end

    class Models_::Script_Adapter < Same__  # algorithm at [#.B]

      def new md, entry
        otr = dup
        otr.__init md, entry
        otr
      end

      def __init md, entry
        @entry = entry
        @name_ = Callback_::Name.via_slug md[ :slug ]
        NIL_
      end

      def name
        @name_
      end

      def under_expression_agent_get_N_desc_lines expag, number_of_lines

        # if description is being requested, we assume that execution
        # will not be requested for this same node (eew)

        # load the file. (note we assume it's never been loaded)

        ::Kernel.load @entry  # result is 'true'

        _pn_s_a = [ * @program_name_string_array, @name_.as_slug ]

        s = @name_.as_lowercase_with_underscores_symbol.id2name
        s[ 0 ] = s[ 0 ].upcase

        _univeral_proc = ::Skylab.const_get s.intern, false

        number_of_lines == @reducer_.number_of_lines or self._SANITY

        @reducer_.lines_by do | out_IO_proxy |

          _univeral_proc.call(

            NOT_TTY___,
            :_no_stdout_for_help_display_,
            out_IO_proxy,
            _pn_s_a,
            [ HELP_ARG___ ],  # must be mutable
          )
        end
      end

      HELP_ARG___ = '-h'.freeze

      class Not_TTY___  # :_[#sy-024]
        def tty?
          false
        end
      end
      NOT_TTY___ = Not_TTY___.new
    end

    class Proxy__

      def initialize
        yield self
        freeze
      end

      define_method :[]=, -> do

        h = {
          :receive_line_args => :"@__receive_line_args",
          :receive_string => :"@__receive_string",
        }

        -> k, p do
          instance_variable_set h.fetch( k ), p
        end
      end.call
    end

    class LTLT_and_Puts_Proxy___ < Proxy__

      def << s
        @__receive_string[ s ]
      end

      def puts * line_a
        @__receive_line_args[ line_a ]
      end
    end

    class Enumerator_Yielder_Proxy___ < Proxy__

      def _same x
        @__receive_string[ x ]
        self
      end

      alias_method :<<, :_same
      alias_method :yield, :_same
    end
  end
end
# :#tombstone: was rewritten
