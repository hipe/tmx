module Skylab::Face

  class CLI::Client

    Version_ = -> do

      norm_h = {
        0 => -> a, b do
          if b
            [ :set_with_block, b ]
          else
            [ :fetch ]
          end
        end,
        1 => -> a, b do
          if b
            raise ::ArgumentError, "can't have block and args for `version`"
          else
            [ :set_with_arg, a[0] ]
          end
        end
      }

      version_option = Option_Sheet.new(  # implemented by `CLI`
        [ '--version', 'show version' ].freeze,
        -> { ( @queue_a ||= [ ] ) << :show_version }
      ).freeze

      op_h = {
        set_with_arg: -> arg do
          instance_exec -> { arg }, & op_h[:set_with_block]
        end,
        set_with_block: -> blk do
          if singleton_class.instance_methods( false ).include? :get_version
            raise ::ArgumentError, "won't overwrite existing `get_version`"
          else
            story.add_option_sheet version_option
            define_singleton_method :get_version, &blk
            if ! method_defined? :show_version
              define_method :show_version do
                y = [ ]
                x = @mechanics.normal_invocation_string and y << x
                x = self.class.get_version and y << x
                y.length.nonzero? and @out.puts( y.join( ' ' ) )
                @argv.length.nonzero? || @queue_a.length.nonzero?
                  # stay (keep processing args) if either of these.
              end
              private :show_version
            end
          end
        end,
        fetch: -> { self.get_version }
      }

      -> cli_cls, a, b do
        op, args = norm_h.fetch( a.length )[ a, b ]
        cli_cls.class_exec( * args, & op_h.fetch( op ) )
      end
    end.call
  end
end
