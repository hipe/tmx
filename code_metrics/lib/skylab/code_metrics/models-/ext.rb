module Skylab::CodeMetrics

  module Home_::Model_::Support

    class Models_::Ext < Report_Action

      edit_entity_class(

        :branch_description, -> y do
          y << "just report on the number of files with different extensions,"
          y << "ordered by frequency of extension"
        end,

        :reuse, COMMON_PROPERTIES.at(
          :exclude_dir,
          :include_name,
        ),

        :parameter_arity, :one,
        :argument_arity, :one_or_more,
        :property, :path,
      )

      def produce_result

        @_totes_class = Totaller_class___[]

        _ok = __resolve_extension_count_box
        _ok && __totaller_via_extension_count_box
      end

      Totaller_class___ = Callback_.memoize do
        Totaller____ = Totaller_[].new
      end

      def __totaller_via_extension_count_box

        _bx = __group_by_count
        __totaller_via_grouped_by_count _bx
      end

      def __group_by_count

        sp = remove_instance_variable :@_specials
        bx = remove_instance_variable :@_extension_box
        bx_ = Callback_::Box.new

        bx.each_pair do | ext, d |
          bx_.touch d do
            []
          end.push Extension___.new( ext )
        end

        if sp
          sp.each_pair do | sym, d |
            bx_.touch d do
              []
          end.push Special___.new( sym )
          end
        end
        bx_
      end

      class Extension___
        def initialize s
          @ext = s
        end
        attr_reader :ext
        def is_special
          false
        end
      end

      class Special___
        def initialize sym
          @sym = sym
        end
        attr_reader :sym
        def is_special
          true
        end
      end

      def __totaller_via_grouped_by_count bx

        totes = @_totes_class.new
        totes.slug = 'Extension Counts'
        y = []
        bx.each_pair do | d, o_a |

          y.clear
          o_a.each do | o |

            y.push( if o.is_special
              Hack_lemma_via_symbol_[ o.sym ]
            else
              "*#{ o.ext }"
            end )
          end

          totes_ = @_totes_class.new
          totes_.slug = y * COMMA___
          totes_.count = d

          totes.append_child_ totes_
        end

        totes.finish
        totes
      end
      COMMA___ = ', '

      def __resolve_extension_count_box

        ok = __resolve_find_files_command
        ok &&= __via_find_files_comand_resolve_file_stream
        ok && __via_file_stream_resolve_extension_count_box
      end

      def __via_file_stream_resolve_extension_count_box

        bx = Callback_::Box.new
        specials = nil

        @_file_stream.each do | file |

          file.chomp!

          ext = ::File.extname file
          if ext.length.zero?

            bn = ::File.basename file
            if DOT_BYTE___ == bn.getbyte( 0 )

              specials ||= Callback_::Box.new
              specials.touch :dotfiles do
                0
              end
              specials.h_[ :dotfiles ] += 1
            end
          else
            bx.touch ext do
              0
            end
            bx.h_[ ext ] += 1
          end
        end

        @_extension_box = bx
        @_specials = specials
        ACHIEVED_
      end

      DOT_BYTE___ = '.'.getbyte 0

      def __via_find_files_comand_resolve_file_stream

        st = line_upstream_via_system_command_ @_find_files_command.args
        if st
          @_file_stream = st
          ACHIEVED_
        else
          st
        end
      end

      def __resolve_find_files_command

        cmd = build_find_files_command_via_paths_ @argument_box.fetch :path
        if cmd

          @on_event_selectively.call :info, :find_files_command do
            cmd.to_event
          end

          @_find_files_command = cmd

          ACHIEVED_
        else
          cmd
        end
      end
    end
  end
end

# :+#tombstone: (please leave this line intact, below was *perfect* [#bs-010])
