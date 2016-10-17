module Skylab::TMX

  module Operations_::Map

    class FrontCLI

      # (this is used to test lowelevel nerks so we gotta duplicate some stuff)

      def initialize i, o, e, pn_s_a
        @serr = e
        @sout = o
        @program_name_string_array = pn_s_a
      end

      def invoke argv
        @exitstatus = 0
        @argv = argv
        if __resolve_bound_call
          bc = remove_instance_variable :@__bound_call
          st = bc.receiver.send bc.method_name, * bc.args, & bc.block
          if st
            y = ::Enumerator::Yielder.new( & @sout.method( :puts ) )
            begin
              x = st.gets
              x || break
              x.express_into y
              redo
            end while above
          end
        end
        @exitstatus
      end

      def __resolve_bound_call
        d = @argv.length
        if d.zero?
          __when_no_args
        elsif Looks_like_opt__[ @argv.first ]
          __when_looks_like_option_at_front
        elsif 1 < d && Looks_like_opt__[ @argv.last ]
          __when_looks_like_option_at_back
        else
          __when_some_args
        end
      end

      def __when_looks_like_option_at_back
        @_unsanitized_option = @argv.last
        @_then = :__after_parsed_last
        _via_unsanitized_option
      end

      def __when_looks_like_option_at_front
        @_unsanitized_option = @argv.first
        @_then = :__after_parsed_first
        _via_unsanitized_option
      end

      def _via_unsanitized_option
        if /\A--?h(?:e(?:lp?)?)?\z/ =~ @_unsanitized_option
          __when_help
        else
          __when_unrecognized_option
        end
      end

      def __when_help
        io = @serr
        io.puts "usage #{ _program_name } #{ _formal_actions } [opts]"
        io.puts
        io.puts "description: experiment.."
        NIL
      end

      def __when_unrecognized_option
        @serr.puts "unrecognized option: #{ @_unsanitized_option.inspect }"
        _invite_to_help
      end

      def __when_no_args
        @serr.puts "expecting #{ _formal_actions }"
        _invite_to_help
      end

      # --

      def __when_some_args

        y = Lazy_.call do
          ::Enumerator::Yielder.new do |s|
            @serr.puts s
          end
        end

        @_emit = -> * i_a, & p do
          if :eventpoint == i_a[0]
            send i_a.fetch 1
          else
             nil.instance_exec y[], & p
            if :parse_error == i_a[2]
              _invite_to_help
            elsif :error == i_a.first
              @exitstatus = 5
            end
          end
          NIL
        end

        _scn = Common_::Polymorphic_Stream.via_array @argv

        @__bound_call = BoundCall_via_Dispatch.new( _scn, & @_emit ).execute

        ACHIEVED_
      end

      def clear_argv
        @argv.clear ; nil
      end

      # --

      def _invite_to_help
        @serr.puts "try '#{ _program_name } -h'"
        _failed
      end

      def _program_name
        ::File.basename @program_name_string_array.last
      end

      def _formal_actions
        "{map}"
      end

      def _failed
        @exitstatus = 5
        UNABLE_
      end

      # ==

      class BoundCall_via_Dispatch

        def initialize scn, & emit
          @scn = scn
          @_emit = emit
        end

        def execute
          if "map" == @scn.current_token
            @scn.advance_one
            __map_money
          else
            __when_unrecognized_action
          end
        end

        def when_unexpected_arguments
          self._NOT_USED
          scn = @scn
          @_emit.call :error, :emission, :parse_error do |y|
            y << "unexpected argument - #{ scn.current_token.inspect }"
          end
          UNABLE_
        end

        def __when_unrecognized_action
          scn = @scn
          @_emit.call :error, :emission, :parse_error do |y|
            y << "unrecognized action #{ scn.current_token.inspect }"
          end
          UNABLE_
        end

        def __map_money

          dir = ::File.expand_path '../../..', Home_.dir_path  # sidesys_path_

          stat = ::File.lstat dir

          if stat.symlink?
            dir_ = ::File.readlink dir
          else
            dir_ = dir
          end

          _yikes = ::File.dirname dir_

          _rcvr = TheMapOperation___.new @scn, _yikes, ::Dir, & @_emit

          Common_::Bound_Call[ nil, _rcvr, :execute ]
        end
      end
    end  # end CLI

    # ==

    class TheMapOperation___

      def initialize scn, dir, filesystem, & p
        @dir = dir
        @_emit = p
        @filesystem = filesystem
        @scn = scn
      end

      def execute

        @_attribute_cache = AttributeCache___.new Home_::Attributes_

        if @scn.no_unparsed_exists
          _attempt_to_produce_stream
        else
          __stream_thru_modifiers
        end
      end

      # --

      def __stream_thru_modifiers
        @_ok = true
        @_additional_formal_attributes = nil
        begin
          if __front_argument_looks_like_primary
            if ! __parse_primary
              break
            end
          elsif ! __parse_map_term
            break
          end
          @scn.no_unparsed_exists ? break : redo
        end while above
        @_ok && __flush_mapped_stream
      end

      def __front_argument_looks_like_primary
        Looks_like_opt__[ @scn.current_token ]
      end

      def __parse_map_term

        _normal_human_string = @scn.current_token

        attr = @_attribute_cache.lookup_formal_attribute_via_normal_human_string(
          _normal_human_string, & @_emit )

        if attr
          @scn.advance_one
          ( @_additional_formal_attributes ||= [] ).push attr
          ACHIEVED_
        else
          attr  # did whine
        end
      end

      def __flush_mapped_stream

        if _store :@__raw_stream, _attempt_to_produce_stream
          __do_flush_mapped_stream
        end
      end

      def __do_flush_mapped_stream

        # for each entity, and then for each attribute (of each entity)..

        require 'json'

        a = remove_instance_variable :@_additional_formal_attributes

        index = @_attribute_cache._index

        remove_instance_variable( :@__raw_stream ).map_by do |node|

          parsed_node = node.parse_against index, & @_emit

          ProcBasedSimpleExpresser_.new do |y|

            buff = node.get_filesystem_directory_entry_string

            if parsed_node
              a.each do |attr|
                buff << SPACE_
                attr.of( parsed_node ).express_into buff
              end
            end

            y << buff
          end
        end
      end

      # --

      def _attempt_to_produce_stream
        if __glob_produces_one_or_more_file
          __produce_stream
        else
          __whine_about_it
        end
      end

      def __glob_produces_one_or_more_file

        @_glob = ::File.join @dir, '*', '.for-tmx-map.json'

        paths = @filesystem.glob @_glob
        if paths.length.zero?
          UNABLE_
        else
          @__paths = paths ; ACHIEVED_
        end
      end

      def __whine_about_it
        glob = @_glob
        @_emit.call :error, :expression do |y|
          y << "found no files for #{ glob }"
        end
        UNABLE_
      end

      def __produce_stream

        Common_::Stream.via_nonsparse_array @__paths do |path|
          Node___.new path
        end
      end

      DEFINITION_FOR_THE_METHOD_CALLED_STORE_ = -> ivar, x do
        if x
          instance_variable_set ivar, x ; ACHIEVED_
        else
          x
        end
      end

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_
    end

    # ==

    class Node___

      def initialize json_file
        @json_file = json_file
      end

      def parse_against index, & p

        json_file = @json_file
        _big_string = ::File.read json_file
        begin
          h = ::JSON.parse _big_string
        rescue ::JSON::ParserError => e
        end

        if e
          p.call :error, :emission, :parse_error do |y|
            y << "    ( while parsing #{ json_file }"
            s_a = e.message.split NEWLINE_
            s_a.each do |s|
              y << "      #{ s }"
            end
            y << "    )"
          end
        else
          Home_::Models_::ParsedNode.via h, index, @json_file, & p
        end
      end

      def express_into y
        y << get_filesystem_directory_entry_string
      end

      def get_filesystem_directory_entry_string
        ::File.basename ::File.dirname @json_file
      end
    end

    # ==

    class AttributeCache___

      def initialize mod
        @module = mod
      end

      def lookup_formal_attribute_via_normal_human_string str, & p
        fo = _index.formal_via_human str
        if fo
          fo
        else
          @_index.levenshtein str, :as_human, & p
        end
      end

      def _index
        @_index ||= Home_::Models_::Attribute::Index.new @module
      end
    end

    # ==

    Looks_like_opt__ = -> do
      d = DASH_.getbyte 0  # DASH_BYTE_
      -> s do
        d == s.getbyte(0)
      end
    end.call

    # ==

    NEWLINE_ = "\n"
    SPACE_ = ' '
  end

  # ==

  class ProcBasedSimpleExpresser_ < ::Proc  # stowaway!
    alias_method :express_into, :call
    undef_method :call
  end

  # ==
end
