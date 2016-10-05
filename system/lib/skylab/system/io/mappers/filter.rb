module Skylab::System

  module IO

    Mappers = ::Module.new  # :+#stowaway

    Autoloader_[ Mappers ]

    def Mappers.const_missing const

      if :Tee == const

        cls = Home_.lib_.basic::Proxy::Makers::Tee.
          call_via_arglist IO_::METHOD_I_A_  # see [#014]

        Mappers.const_set :Tee, cls

        cls.class_exec do

          def tty?
            @this_system_IO_tee_is_a_tty
          end
        end
        cls

      else
        super
      end
    end

    class Mappers::Filter  # :[#012]

      # intercept write-like messages intended for an ::IO, but do something
      # magical with the content. Don't forget to call `flush!` at the end.

      Attributes_actor_.call( self,
        downstream_IO: nil,
        niladic_pass_filter_proc: nil,
      )

      class << self

        def [] x  # sort of like #[#ca-057]
          new_with :downstream_IO, x
        end

        private :new
      end  # >>

      def initialize

        @_do_check_for_line_boundaries = false

        @_line_begin_p = @_line_end_p = nil

        @niladic_pass_filter_proc = @_puts_map_p_a = nil

        @_was_newline = true
      end

      def process_polymorphic_stream_passively st  # #[#fi-022]
        super && normalize
      end

      def normalize
        @niladic_pass_filter_proc ||= NILADIC_TRUTH_
        KEEP_PARSING_
      end

    private

      def line_begin_string=

        s = gets_one_polymorphic_value
        if s
          _set_line_begin_proc -> { @downstream_IO.write s }
        end
        KEEP_PARSING_
      end

      def line_begin_proc=

        p = gets_one_polymorphic_value
        if p
          _set_line_begin_proc p
        end
        KEEP_PARSING_
      end

      def line_end_proc=

        p = gets_one_polymorphic_value
        if p
          _set_line_proc :@_line_end_p, p
        end
        KEEP_PARSING_
      end

      def _set_line_begin_proc p

        _set_line_proc :@_line_begin_p, p
        NIL_
      end

      def _set_line_proc ivar, p

        instance_variable_set ivar, p
        @_do_check_for_line_boundaries = true
        NIL_
      end

      def puts_map_proc=

        # each data passed to puts will first be run through each filter
        # in the order received in a reduce operation, the result being
        # what is finally passed to puts

        p = gets_one_polymorphic_value
        if p
          ( @_puts_map_p_a ||= [] ).push p
        end
        KEEP_PARSING_
      end

    public

      # -- Readers & delegators

      def tty?  # (more in history)
        false
      end

      def downstream_IO
        @downstream_IO
      end

      %i( close closed? rewind truncate ).each do | sym |

        define_method sym do | * a |

          if @downstream_IO.respond_to? sym
            @downstream_IO.send sym, * a
          end
        end
      end

      def puts *a
        if _yes
          __puts_via_array a
        end
      end

      def << str
        if _yes
          _write str
        end
        self
      end

      def write str
        if _yes
          _write str
        else
          "#{ str }".length
        end
      end

      def _yes
        @niladic_pass_filter_proc.call
      end

      def __puts_via_array a

        a = a.flatten
        if a.length.zero?
          a.push EMPTY_S_
        end

        a.each do | s |

          if @_puts_map_p_a
            s = @_puts_map_p_a.reduce s do | m, p |
              p[ m ]
            end
          end

          s = s.to_s

          if NEWLINE_CHAR___ != s.getbyte( -1 )
            s = "#{ s }#{ NEWLINE_ }"
          end

          _write s  # route everything through write()
        end

        NIL_  # per ::IO#puts, but consider it undefined.
      end

      NEWLINE_CHAR___ = NEWLINE_.getbyte 0

      def _write s

        if s.length.zero? || ! @_do_check_for_line_boundaries

          @downstream_IO.write s  # result is bytes
        else
          __write_while_checking_for_line_boundaries s
        end
      end

      def __write_while_checking_for_line_boundaries str

        was_NL = @_was_newline
        @_was_newline = NEWLINE_ == str[ -1 ]

        a = str.split NEWLINE_, -1
        last_d = a.length - 1

        a.each_with_index do | s, d |

          is_subsequent = d.nonzero?
          _is_not_last = last_d != d
          has_width = s.length.nonzero?

          if is_subsequent

            @downstream_IO.write NEWLINE_

            if @_line_end_p
              @_line_end_p[]
            end
          end

          if is_subsequent || was_NL and
              _is_not_last || has_width and
              @_line_begin_p

            @_line_begin_p[]
          end

          if has_width
            @downstream_IO.write s
          end
        end

        str.length
      end
    end
  end
end
