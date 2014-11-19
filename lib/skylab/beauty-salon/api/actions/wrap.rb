module Skylab::BeautySalon

  class API::Actions::Wrap < API::Action

    params [ :lines, :normalizer, true, :arity, :zero_or_one ],
           [ :num_chars_wide, :normalizer, true, :arity, :one ],
           [ :do_preview, :arity, :zero_or_one ],
           [ :be_verbose, :arity, :zero_or_one ],
           [ :do_number_the_lines, :arity, :zero_or_one ],
           [ :file, :arity, :one ]

    listeners_digraph :info_line, :info_string, :normalization_failure_line_notify

    services [ :ostream, :ivar ] , [ :estream, :ivar ]

    def execute
      res = false ; head = nil
      begin
        ok, res = preexecute
        ok or break
        @scn = resolve_line_scanner or break
        @token_buffer = BS_._lib.token_buffer %r([[:space:]]*), %r([^[:space:]]+)
        ok = true
        while line = @scn.gets
          if @line_range_union.include? @scn.count
            engage( line ) or break( ok = false )
          elsif @do_preview
            if @be_verbose
              if @do_number_the_lines
                head = " #{ @line_no_fmt % @scn.count }: "
              end
              @estream.puts "#{ head }#{ line }"
            end
          else
            @paystream.write line
          end
        end
        ok or break
        @scn.count.zero? and info_string "(file had no lines - #{ @file })"
        if ! @did_engage
          info_string "(the lines of the file (#{
            @scn.count.zero? ? 'none' : "1-#{ @scn.count }" }) did not #{
            }intersect with the selected lines (#{
            }#{ @line_range_union.describe }))"
        end
        res = true
      end while nil
      res
    end

  private

    # [#fa-019]

    -> do
      rx = /\A\d+\z/
      define_method :normalize_num_chars_wide do |y, x, z|
        x = x.to_s ; ok = nil
        if rx =~ x
          fixnum = x.to_i
          if 1 <= fixnum  # eek
            z[ fixnum ]
            ok = true
          else
            y << "needs a positive integer, had: #{ x }"
          end
        else
          y << "can't discern a positive integer from #{ x.inspect }"
        end
        ok
      end
    end.call

    # [#fa-019] assume that x is nil or an array.

    def normalize_lines y, x, z
      ok = y.count ; unio = BS_._lib.range_lib::Positive::Union.new
      if x
        inputs = BS_._lib.list_scanner x
        parse = BS_._lib.range_lib::Positive::List::Scanner.new
        parse.unexpected_proc = -> xx, exp_a do
          _excerpt = Ellipsulate__[ xx ]
          y << "didn't understand \"#{ _excerpt }\" in the #{
            }lines expression - expected a #{ exp_a * ' or ' }"
          nil  # IMPORTANT - it must break the scan loop
        end
        unio.unexpected_proc = -> xx do
          y << "can't understand lines because #{ xx }"
        end
        while ! inputs.eos?
          parse.string = inputs.gets
          while r = parse.gets
            unio.add r or break
          end
          ok == y.count or break
        end
        if ok == y.count
          z[ nil ]  # for clarity we change the ivar
        else
          unio = nil  # fail loudly if we try to access it
        end
      end
      @line_range_union = unio.prune if unio
      true if ok == y.count
    end

    A_RATHER_SHORT_LEN__ = 8

    Ellipsulate__ = BS_._lib.CLI_lib.ellipsify.
      curry[ A_RATHER_SHORT_LEN__ ]

    def resolve_line_scanner
      res = nil
      begin
        fh = resolve_file or break
        res = BS_._lib.list_scanner fh
      end while nil
      res
    end

    def resolve_file
      begin
        ::File.open @file
      rescue ::Errno::ENOENT => e
        normalization_failure_line_notify e.message
        nil
      end
    end

    def preexecute  # #result is tuple
      @did_engage = nil ; @line_no_fmt = '%4d'  # meh
      if @do_preview
        @paystream = @estream
      else
        @paystream = @ostream
      end
      @be_verbose and info_string "line range union: (#{ @line_range_union.describe })"
      @engage_head = nil
      if @do_preview and @be_verbose and @do_number_the_lines
        @engage_head = "     + "  # ick
      end
      [ true, nil ]
    end

    def engage line  # assume @scn and `line` and result should be t|f

      @did_engage ||= true

      @token_buffer.gets_proc = -> do
        @token_buffer.gets_proc = -> do
          if @line_range_union.include?( @scn.count + 1 )
            @scn.gets  # #todo
          end
        end
        line
      end

      @line_buffer ||= BS_::Models::Line::Buffer.new(
        @num_chars_wide, -> oline do
          @paystream.write "#{ @engage_head }#{ oline }"
        end
      )

      while word = @token_buffer.gets
        @line_buffer << word
      end

      @line_buffer.flush

      true
    end
  end
end
