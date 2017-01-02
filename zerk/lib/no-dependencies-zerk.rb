module NoDependenciesZerk

  # freshly abtracted from [cm], officially this is [#060]

  # when you need to make a client that doesn't load a lot of files
  # (like one that turns on coverage testing or similar), this is a
  # single-file implementation of the basics needed to make API & CLI

  # -

    Lazy = -> & p do
      yes = true ; x = nil
      -> do
        if yes
          yes = false ; x = p[]
        end
        x
      end
    end

    SimpleModel = ::Class.new  # forward declaration

    # = CLI life

    ArgumentScannerMethods__ = ::Module.new  # forward declaration

    class CLI_ArgumentScanner < SimpleModel

      include ArgumentScannerMethods__

      def initialize

        @_read_CPS = :__read_CPS_initially
        @_write_CPS = :__write_CPS_initially

        @initial_ARGV_offset = 0
        @default_primary_symbol = nil
        @listener = nil
        yield self
        s_a = remove_instance_variable :@ARGV
        len = s_a.length
        d = remove_instance_variable :@initial_ARGV_offset
        if len == d
          @no_unparsed_exists = true
          freeze
        else
          @_array = s_a
          @_current_index = d
          @_last_index = s_a.length - 1
        end
      end

      attr_writer(
        :ARGV,
        :default_primary_symbol,
        :initial_ARGV_offset,
        :listener,
      )

      # --

      def parse_primary  # exactly as [#ze-052.1] canon
        s = head_as_is
        md = RX___.match s
        if md
          _ = md[ 1 ].gsub( DASH_, UNDERSCORE_ ).intern
          send @_write_CPS, _
          advance_one
          ACHIEVED_
        elsif @default_primary_symbol
          # #not-covered - blind faith
          send @_write_CPS, @default_primary_symbol
          ACHIEVED_
        else
          __when_malformed_primary s
        end
      end

      RX___ = /\A--?([a-z0-9]+(?:-[a-z0-9]+)*)\z/i

      def __write_CPS_initially sym
        @_read_CPS = :__read_CPS_normally
        @_write_CPS = :__write_CPS_normally
        send @_write_CPS, sym
      end

      def __write_CPS_normally sym
        @_current_primary_symbol = sym ; nil
      end

      def __read_CPS_initially
        raise ScannerIsNotInThatState,
          "cannot read `current_primary_symbol` from beginning state"
      end

      def __read_CPS_normally
        @_current_primary_symbol
      end

      # --

      def fuzzy_lookup_or_fail h  # assume CPS

        rx = /\A#{ ::Regexp.escape current_primary_symbol.id2name }/
        a = []
        h.keys.each do |k|
          rx =~ k or next
          a.push k
        end
        case 1 <=> a.length
        when 0
          k = a.fetch 0
          @_current_primary_symbol = k
          h.fetch k
        when 1
          When_not_found__[ h, self ]
        else
          __when_ambiguous a
        end
      end

      def parse_positive_nonzero_integer
        d = __integer_that { |d_| 0 < d_ }
        d && advance_one
        d
      end

      def __integer_that & p
        d = __head_as_integer
        if d
          if yield d
            d
          else
            __when_integer_is_not d, caller_locations( 1, 1 )[ 0 ]
          end
        end
      end

      def __when_integer_is_not d, loc
        _s = %r(\Aparse_(.+)_integer\z).match( loc.base_label )[ 1 ]
        _human = _s.gsub UNDERSCORE_, SPACE_
        no_because { "{{ prim }} must be #{ _human } (had #{ d })" }
      end

      def __head_as_integer
        map_value_by do |s|
          if %r(\A-?\d+\z) =~ s
            s.to_i
          else
            no_because { "{{ prim }} must be an integer (had #{ s.inspect })" }
          end
        end
      end

      # --

      def __when_ambiguous a
        k = current_primary_symbol
        no_because do |y|
          _scn = Scanner_via_Array.call( a ) { |sym| prim sym }
          y << "ambiguous primary #{ ick_prim k } - #{
            }did you mean #{ oxford_or _scn }?"
        end
      end

      def __when_malformed_primary s
        no_because do |y|
          y << "does not look like primary: #{ s.inspect }"
        end
      end

      # --

      def advance_one
        if @_last_index == @_current_index
          remove_instance_variable :@_array
          remove_instance_variable :@_current_index
          remove_instance_variable :@_last_index
          @no_unparsed_exists = true
          # can't freeze because the current primary may be set
        else
          @_current_index += 1
        end
        NIL
      end

      # --

      def current_primary_symbol
        send @_read_CPS
      end

      def head_as_is
        @_array.fetch @_current_index
      end

      attr_reader(
        :listener,
        :no_unparsed_exists,
      )

      ScannerIsNotInThatState = ::Class.new ::RuntimeError
    end

    # ==

    ExpressionAgent__ = ::Class.new  # forward declaration

    class CLI_ExpressionAgent < ExpressionAgent__

      def ick_prim sym
        prim( sym ).inspect
      end

      def prim sym
        "-#{ sym.id2name.gsub UNDERSCORE_, DASH_ }"
      end
    end

    # = API life

    class API_ArgumentScanner

      include ArgumentScannerMethods__

      def initialize a, & l
        @_current_primary = :__current_primary_invalid
        @_receive_current_primary = :__receive_first_ever_current_primary
        @listener = l  # not used here presently, just a courtesy
        if a.length.zero?
          @no_unparsed_exists = true
          freeze
        else
          @_array = a
          @_current_index = 0
          @_last_index = a.length - 1
        end
      end

      def parse_primary
        # (we don't check if it's a symbol but we could)
        send @_receive_current_primary, head_as_is
        advance_one
        true
      end

      def __receive_first_ever_current_primary sym
        @_current_primary = :__current_primary_normally
        @_receive_current_primary = :__receive_current_primary_normally
        send @_receive_current_primary, sym
      end

      def __receive_current_primary_normally sym
        @__current_primary_value = sym ; nil
      end

      def fuzzy_lookup_or_fail h
        When_not_found__[ h, self ]
      end

      def current_primary_symbol
        send @_current_primary
      end

      def __current_primary_invalid
        raise ScannerIsNotInThatState,
          "cannot read `current_primary_symbol` from beginning state"
      end

      def __current_primary_normally
        @__current_primary_value
      end

      def advance_one
        if @_last_index == @_current_index
          remove_instance_variable :@_array
          remove_instance_variable :@_current_index
          remove_instance_variable :@_last_index
          @no_unparsed_exists = true
          freeze
        else
          @_current_index += 1
        end
        NIL
      end

      def head_as_is
        @_array.fetch @_current_index
      end

      attr_reader(
        :listener,
        :no_unparsed_exists,
      )

      # ===

      ScannerIsNotInThatState = ::Class.new ::RuntimeError

      # ===
    end

    # ==

    class API_ExpressionAgent < ExpressionAgent__

      def ick_prim sym
        prim sym
      end

      def prim sym
        "'#{ sym.id2name }'"
      end
    end

    # = modality-agnostic life

    Check_requireds = -> o, ivars, & p do
      when_missing = nil
      missing = nil
      main = -> do
        ivars.each do |ivar|
          if ! o.instance_variable_get ivar
            _sym = ivar.id2name.gsub( %r(\A@|s\z), EMPTY_S_ ).intern # sneaky
            ( missing ||= [] ).push _sym
          end
        end
        if missing
          when_missing[]
        else
          ACHIEVED_
        end
      end

      when_missing = -> do
        p.call :error, :expression, :primary_parse_error do |y|
          _scn = Scanner_via_Array.call missing do |sym|
            prim sym
          end
          _and = oxford_and _scn
          y << "required: #{ _and }"
        end
        UNABLE_
      end

      main[]
    end

    class ParseArguments_via_PrimariesInjections

      class << self
        def call_by & p
          new( & p ).execute
        end
        private :new
      end  # >>

      def initialize
        @_add_primaries_injection = :__add_first_primaries_injection
        yield self
        remove_instance_variable :@_add_primaries_injection
      end

      def argument_scanner as
        @__argument_scanner = as ; nil
      end

      def add_primaries_injection h, injector
        send @_add_primaries_injection, h, injector
      end

      def __add_first_primaries_injection h, inj
        h_ = {}
        h.each_pair do |k, m|
          h_[ k ] = [ 0, m ]  # ..
        end
        @_primaries = h_
        @_injectors = [ inj ]
        @_add_primaries_injection = :__add_subsequent_primaries_injection
        NIL
      end

      def __add_subsequent_primaries_injection h, inj
        h_ = @_primaries
        idx = @_injectors.length
        h.each_pair do |k, m|
          h_[ k ] = [ idx, m ]  # meh for now just overwrite
        end
        @_injectors[idx] = inj
        NIL
      end

      def execute
        args = remove_instance_variable :@__argument_scanner
        a = remove_instance_variable :@_injectors
        h = remove_instance_variable :@_primaries
        ok = true
        until args.no_unparsed_exists
          ok = args.parse_primary
          ok || break
          tuple = h[ args.current_primary_symbol ]
          if ! tuple
            tuple = args.fuzzy_lookup_or_fail h
          end
          if ! tuple
            ok = tuple ; break
          end
          ok = a.fetch( tuple[0] ).send tuple[1]
          ok || break
        end
        ok
      end
    end

    module ArgumentScannerMethods__

      def current_primary_as_ivar
        :"@#{ current_primary_symbol }"
      end

      def map_value_by
        if no_unparsed_exists
          no_because { "{{ prim }} requires an argument" }
        else
          yield head_as_is
        end
      end

      def no_because reason_symbol=:primary_parse_error, & msg_p

        scn = self
        @listener.call :error, :expression, reason_symbol do |y|

          map = -> sym do
            case sym
            when :prim
              prim scn.current_primary_symbol
            end
          end

          _y = ::Enumerator::Yielder.new do |line|
            y << ( line.gsub %r(\{\{[ ]*([a-z_]+)[ ]*\}\}) do
              map[ $~[1].intern ]
            end )
          end

          if msg_p.arity.zero?
            _y << calculate( & msg_p )
          else
            calculate _y, & msg_p
          end
          y
        end

        UNABLE_
      end
    end

    When_not_found__ = -> h, scn do
      k = scn.current_primary_symbol
      scn.no_because do |y|
        _scn = Scanner_via_Array.call( h.keys ) { |sym| prim sym }
        y << "unknown primary: #{ ick_prim k }"
        y << "available primaries: #{ oxford_and _scn }"
      end
    end

    class ExpressionAgent__

      class << self
        def instance
          @___instance ||= new
        end
      end

      alias_method :calculate, :instance_exec

      def oxford_or scn
        _oxford_join scn, ' or ', ', '
      end

      def oxford_and scn
        _oxford_join scn, ' and ', ', '
      end

      def _oxford_join scn, ult, nonult
        buff = scn.gets_one.dup
        if ! scn.no_unparsed_exists
          begin
            s = scn.gets_one
            scn.no_unparsed_exists && break
            buff << nonult << s
            redo
          end while above
          buff << ult << s
        end
        buff
      end
    end

    # = support

    class Scanner_via_Array

      class << self
        def call d=nil, a, & p
          scn = new d, a
          if block_given?
            Mapped_Scanner___.new p, scn
          else
            scn
          end
        end
        alias_method :[], :call
      end  # >>

      def initialize d=nil, a
        d ||= 0
        len = a.length
        if len == d
          @no_unparsed_exists = true ; freeze
        else
          @_array = a
          @_len = len
          @_pos = d
        end
      end

      def gets_one
        x = current_token
        advance_one
        x
      end

      def advance_one
        d = @_pos + 1
        if @_len == d
          @no_unparsed_exists = true
          remove_instance_variable :@_array
          remove_instance_variable :@_len
          remove_instance_variable :@_pos
          freeze
        else
          @_pos = d
        end
        NIL
      end

      def current_token
        @_array.fetch @_pos
      end

      attr_reader(
        :no_unparsed_exists,
      )
    end

    class Mapped_Scanner___

      def initialize p, scn
        @_proc = p
        @_scn = scn
      end

      def gets_one
        @_proc[ @_scn.gets_one ]
      end

      def current_token  # ..
        @_proc[ @_scn.current_token ]
      end

      def advance_one
        @_scn.advance_one
      end

      def no_unparsed_exists
        @_scn.no_unparsed_exists
      end
    end

    # ==

    class SimpleModel

      class << self
        alias_method :define, :new
        private :new
      end  # >>

      def initialize
        yield self
        freeze
      end

      private :dup

      def redefine
        otr = dup
        yield otr
        otr.freeze
      end
    end

    # ==

    ACHIEVED_ = true
    DASH_ = '-'
    EMPTY_S_ = ''
    SPACE_ = ' '
    UNABLE_ = false
    UNDERSCORE_ = '_'

    # ==
  # -
end
