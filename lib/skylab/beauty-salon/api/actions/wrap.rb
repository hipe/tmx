module Skylab::BeautySalon

  class API::Actions::Wrap < API::Action

    params [ :lines, :normalizer, true ],
           [ :num_chars_wide, :normalizer, true, :required ],
           :do_preview,
           :be_verbose,
           :do_number_the_lines,
           [ :file, :required ]

    emits :info_line, :info, :normalization_failure_line,
      :modality_host_proxy_request

    services :ostream, :estream

    def execute
      preexecute
      res = false ; head = nil
      begin
        @scn = resolve_line_scanner or break
        @token_buffer = Basic::Token::Buffer.new(
          /[[:space:]]*/, /[^[:space:]]+/ )
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
        @scn.count.zero? and info "(file had no lines - #{ @file })"
        if ! @did_engage
          info "(the lines of the file (#{
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
      define_method :normalize_num_chars_wide do |y, x, result_if_ok|
        x = x.to_s
        if rx =~ x
          fixnum = x.to_i
          if 1 <= fixnum  # eek
            result_if_ok[ fixnum ]
          else
            y << "needs a positive integer, had: #{ x }"
          end
        else
          y << "can't discern a positive integer from #{ x.inspect }"
        end
        nil
      end
    end.call

    # [#fa-019] assume that x is nil or an array.

    def normalize_lines y, x, result_if_ok
      unio = Basic::Range::Positive::Union.new
      if x
        inputs = Basic::List::Scanner[ x ]
        parse = Basic::Range::Positive::List::Scanner.new
        parse.unexpected_proc = -> xx, exp_a do
          y << "didn't understand \"#{
            Services::Headless::CLI::FUN.ellipsify[ xx , 8 ] }\" in the #{
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
          y.count.zero? or break
        end
        if y.count.zero?
          result_if_ok[ nil ]  # for clarity we change ivars
        else
          unio = nil  # let's get warned if we access the ivar
        end
      end
      if unio
        @line_range_union = unio.prune
      end
      nil  # not important
    end

    def resolve_line_scanner
      res = nil
      begin
        fh = resolve_file or break
        res = Basic::List::Scanner[ fh ]
      end while nil
      res
    end

    def resolve_file
      begin
        ::File.open @file
      rescue ::Errno::ENOENT => e
       normalization_failure_line e.message
       nil
      end
    end

    def preexecute
      @did_engage = nil ; @line_no_fmt = '%4d'  # meh

      # hack access to mode client services:
      emit :modality_host_proxy_request,  self, -> host_pxy { @host = host_pxy }
      @ostream, @estream = @host[ :ostream, :estream ]
      if @do_preview
        @paystream = @estream
      else
        @paystream = @ostream
      end
      @be_verbose and info "line range union: (#{ @line_range_union.describe })"
      @engage_head = nil
      if @do_preview and @be_verbose and @do_number_the_lines
        @engage_head = "     + "  # ick
      end
      nil
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

      @line_buffer ||= BeautySalon::Models::Line::Buffer.new(
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
