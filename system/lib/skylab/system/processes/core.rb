module Skylab::System

  Processes = ::Module.new

  class Processes::Service  # [#031].

    # hack a façade for this. a placeholder for whatever the right way is

    def initialize x
      @_mama = x
    end

    o = {}

    o[ :etime ] = -> fld do

      epoch = Time.new 1970, 1, 1, 0, 0, 0, 0

      rx = /\A(?:(?<days>[0-9]+)-)?(?:(?<H>\d\d):)?(?<M>\d\d):(?<S>\d\d)\z/

      fld.interpret = -> s, & p do

        md = rx.match s

        d = 0
        s = md[ :days ]
        if s
          d += s.to_i * 86400  # days
        end
        d += md[ :H ].to_i * 3600  # hours
        d += md[ :M ].to_i * 60  # minutes
        d += md[ :S ].to_i  # seconds

        Common_::KnownKnown[ epoch + d ]
      end
    end

    o[ :pid ] = -> fld do

      fld.interpret = -> s, & p do

        if s
          Common_::KnownKnown[ s.to_i ]
        end
      end
    end

    o[ :state ] = -> fld do

      fld.interpret = -> s, & p do
        if s
          Common_::KnownKnown[ s ]
        end
      end
    end

    cache = {}
    Lookup_field___ = -> sym do
      cache.fetch sym do

        _defn = o.fetch sym

        _nf = Common_::Name.via_lowercase_with_underscores_symbol sym

        fld = Field___.new _nf, & _defn
        cache[ sym ] = fld
        fld
      end
    end

    class Field___

      def initialize nf
        @name = nf
        yield self
        freeze
      end

      def interpret= p
        @_interpretation_proc = p
      end

      def interpret s
        @_interpretation_proc[ s ]
      end

      attr_reader(
        :name,
      )
    end

    def record_for d, * sym_a, & p
      Record_For___.new( d, sym_a,  @_mama, & p ).execute
    end

    class Record_For___

      def initialize d, sym_a, mama, & p
        @d = d
        @_mama = mama
        @_listener = p
        @sym_a = sym_a
      end

      def execute

        ok = ___normalize_PID
        ok && __sort_fields
        ok && __init_struct_class
        ok && __init_command
        ok && __send_and_receive
      end

      def ___normalize_PID

        s = "#{ @d }"
        if SANITY_RX___ =~ s
          @_normalized_PID = s
          ACHIEVED_
        else
          self._COVER_ME
        end
      end

      SANITY_RX___ = /\A\d+\z/

      def __sort_fields

        fld_a = @sym_a.map do | sym |
          Lookup_field___[ sym ]
        end

        fld_a.sort_by! do | fld |
          fld.name.as_lowercase_with_underscores_string
        end

        @_sorted_fields = fld_a
        NIL_
      end

      def __init_struct_class

        @_struct_class = Struct_class_for_sorted_field_a___[ @_sorted_fields ]
        NIL_
      end

      def __init_command

        cmd = [ 'ps' ]
        @_sorted_fields.each do | fld |
          s = fld.name.as_lowercase_with_underscores_string
          cmd.push "-o#{ s }=#{ s }"
        end
        cmd.push '-p', @_normalized_PID
        @_command = cmd
        NIL_
      end

      def __send_and_receive

        # $stderr.puts "CMD: #{ @_command.join SPACE_ }"

        _i, @_o, @_e, @_w = @_mama.popen3( * @_command )

        @_header = @_o.gets
        if @_header
          __when_header
        else
          _flush_zero_or_more_error_lines
        end
      end

      def __when_header

        @_first = @_o.gets
        if @_first
          __when_first
        else
          ___when_no_first
        end
      end

      def ___when_no_first

        s = @_e.gets
        if s
          self._COVER_ME_its_easy_just_flush_the_error
        else

          d = @_w.value.exitstatus
          if 1 == d
            Common_::KNOWN_UNKNOWN
          else
            self._COVER_ME_no_stdout_or_stderr_and_non_one_exitstatus
          end
        end
      end

      def __when_first

        @_second = @_o.gets

        if @_second

          self.__WHEN_SECOND

        elsif @_w.value.exitstatus.zero?

          x = Record___[ @_first, @_header, @_struct_class, @_sorted_fields ]
          x or self._REDESIGN
          Common_::KnownKnown[ x ]

        else
          self.__ROLL
        end
      end

      def _flush_zero_or_more_error_lines s=nil

        e = @_e ; w = @_w
        s ||= e.gets

        @_listener.call :error, :expression, :etc do | y |

          es = -> do
            " (exitstatus: #{ w.value.exitstatus })"
          end

          if s
            p = -> s_ do
              p = -> s__ do
                y << " >> #{ s }"
              end
              y << "system did't behave as expected: #{ s_ }"
            end
            begin
              next_s = e.gets
              next_s or break
              next_s.chomp!
              p[ s ]
              s = next_x
              redo
            end while nil
            p[ s ]
          else
            y << "no error from system call#{ es[] }"
          end
        end
        UNABLE_
      end
    end

    Struct_class_for_sorted_field_a___ = -> fld_a do

      _const_s_a = fld_a.map do | fld |
        fld.name.as_camelcase_const_string
      end

      const = _const_s_a.join( UNDERSCORE_ ).intern

      mod = Sandbox___

      if mod.const_defined? const, false

        mod.const_get const, false

      else

        _member_sym_a = fld_a.map do | fld |
          fld.name.as_lowercase_with_underscores_symbol
        end

        cls = ::Struct.new( * _member_sym_a )
        mod.const_set const, cls
        cls
      end
    end

    Record___ = -> first, header, struct_class, fields do

      _p = Build_record_builder___[ header, struct_class, fields ]

      _p[ first ]
    end

    sp_rx = /[ ]*/  # the first field header may not have leading space
    sp_rx_ = /[ ]+/  # you need more than 1 on all but the first record

    w_rx = /[^[:space:]]+/

    Build_record_builder___ = -> header, struct_class, fields do

      ranges = []

      d = 0
      field_st = Common_::Stream.via_nonsparse_array fields
      scn = Home_.lib_.string_scanner header

      sep = -> do
        x = scn.skip sp_rx
        sep = -> do
          scn.skip sp_rx_
        end
        x
      end

      begin

        sp_d = sep[]
        sp_d or break

        w_s = scn.scan w_rx
        w_s or break

        fld = field_st.gets
        fld or break

        if fld.name.as_lowercase_with_underscores_string != w_s
          self._COVER_ME
        end

        d_ = d + sp_d + w_s.length
        ranges.push d ... d_

        d = d_
        redo
      end while nil

      if sp_d
        self._COVER_ME_trailing_whitespace
      elsif ! fld
        self._COVER_ME_unexpected_records
      end

      times = fields.length

      -> line do
        struct = struct_class.new
        times.times do | idx |

          s = line[ ranges.fetch idx ]
          s.strip!

          field = fields.fetch idx

          _k = field.name.as_lowercase_with_underscores_symbol
          wv = field.interpret s
          if wv
            struct[ _k ] = wv.value
          else
            self._COVER_ME
          end
        end
        struct
      end
    end

    Sandbox___ = self
  end
end
