module Skylab::Snag
  class Services::Manifest

    def build_enum issue_flyweight, error, info
      Models::Node::Enumerator.new do |y|
        begin
          if ! pathname?
            error[ "manifest pathname was not resolved" ]
            break
          end
          if ! pathname.exist?
            info[ "manifeset file didn't exist - no issues." ]
            break
            # (if pathname is resolved (i.e. we know what it *should* be)
            # and it doesn't exist, there are simply no issues.)
          end
          if ! issue_flyweight
            issue_flyweight = Models::Node.new nil, pathname
          end
          file.lines.each_with_index do |line, idx|
            ln = issue_flyweight.line! line, idx
              # (for now we go ahead and throw in the invalid ones too)
            y << ln
          end
        end while nil
      end
    end


    issue_number_digits = 3

    add_struct = ::Struct.new :date, :dry_run, :error,
                                :escape_path, :info, :message, :verbose

    define_method :add_issue do |&block|
      res = false
      begin
        block[ o = add_struct.new ]
        if ! normalize_date o
          break
        end
        if ! normalize_message o
          break
        end
        int = greatest_issue_integer + 1
        id = "[##{   "%0#{ issue_number_digits }d" % int   }]"
        line = "#{ id } #{ o[:date] } #{ o[:message] }"
        o.info[ "new line: #{ line }" ]
        res = add_line_to_top line, o
        break if ! res
        o.info[ "done." ]
      end while nil
      res
    end

    def pathname
      @pathname or fail 'sanity - pathname is not known. use `pathname?`'
      @pathname
    end

    def pathname?
      !! @pathname
    end

  protected

    def initialize pathname
      @file = nil
      @pathname = ::Pathname.new pathname
      @tmpdir_pathname = nil
    end

    dev_null = ::Object.new                    # hehe the sneaky hoops we jump
    dev_null.define_singleton_method( :puts ) { |s| } # thru to get a good dry

    define_method :add_line_to_top do |line, o|
      res = false
      begin
        fail "implement me - create file" if ! pathname.exist?
        fu = self.fu( o )
        tmpdir_pathname = self.tmpdir_pathname o, fu
        break if ! tmpdir_pathname
        tmpold = tmpdir_pathname.join 'issued.md.prev'
        tmpnew = tmpdir_pathname.join 'issues.md.next'
        if tmpnew.exist?
          fu.rm tmpnew, noop: o.dry_run
        end
        write = -> fh do
          fh.puts line                         # ~ put the newline at the top ~
          file.lines.each do |lin|             # #open-filehandle
            fh.puts lin                        # (but tested quite well)
          end
        end
        if o.dry_run
          write[ dev_null ]                    # sneaky
        else
          tmpnew.open( 'w+' ) do |fh|
            write[ fh ]
          end
        end
        if tmpold.exist?
          fu.rm tmpold, noop: o.dry_run
        end
        fu.mv pathname, tmpold, noop: o.dry_run
        fu.mv tmpnew, pathname, noop: o.dry_run
        res = true
      end while nil
      res
    end

    def file
      file = nil
      begin
        break( file = @file ) if @file
        @pathname or fail 'sanity'
        file = Models::Node::File.new @pathname
        @file = file
      end while nil
      file
    end

    def fu o                                   # Using a hacky regex, scan
      rx = Headless::CLI::PathTools::FUN.absolute_path_hack_rx # all messages emitted
      fu = Headless::IO::FU.new( -> str do     # from the file utils client,
        s = str.gsub( rx ) do                  # and run everything that looks
          o.escape_path[ $~[0] ]               # like an absolute path thru
        end                                    # the `escape_path` implemen.
        o.info[ s ] if o.verbose               # *of the modality client*
      end )                                    # In turn, emit this messages
      fu                                       # as info to the same client.
    end

    def greatest_issue_integer
      enum = build_enum nil, nil, nil
      enum = enum.valid
      greatest = enum.reduce( -1 ) do |m, issue|
        x = issue.integer
        m > x ? m : x
      end
      greatest
    end


    valid_date_rx = %r{ \A \d{4} - \d{2} - \d{2} \z }x

    define_method :normalize_date do |o|
      res = false
      begin
        if valid_date_rx !~ o[:date]
          o.error and error[ "invalid date: #{ o[:date].inspect }" ]
          break
        end
        res = true
      end while nil
      res
    end


    blank_rx = /\A[[:space:]]*\z/
    nl_rx = /\n/
    xnl_rx = /\\n/

    define_method :normalize_message do |o|
      res = false
      begin
        msg = o[:message].to_s
        err = o[:error] ? o[:error] : -> s { }
        break( err[ "message was blank." ] ) if blank_rx =~ msg
        break( err[ "message cannot contain newlines." ] ) if nl_rx =~ msg
        if xnl_rx =~ msg
          err[ "message cannot contain (escaped or unescaped) newlines." ]
          break
        end
        res = true
      end while nil
      res
    end

    def tmpdir_pathname o, fu
      res = false
      begin
        break( res = @tmpdir_pathname ) if @tmpdir_pathname
        pn = ::Skylab::TMPDIR_PATHNAME.join 'issue-PROD' # heh
        if ! pn.dirname.exist?
          o.error and o.error[ "won't create more than one directory. #{
            }Parent directory of our tmpdir (#{ pn.basename }) must exist: #{
            }#{ escape_path pn.dirname }" ]
          break
        end
        if ! pn.exist?
          fu.mkdir( pn, noop: o.dry_run )
        end
        res = @tmpdir_pathname = pn
      end while nil
      res
    end
  end
end
