module Skylab::Snag
  class Services::Manifest

    def build_enum node_flyweight, error, info
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
          node_flyweight ||= Models::Node::Flyweight.new nil, pathname
          node_flyweight.each_node file.normalized_line_producer, y
          nil
        end while nil
      end
    end

    node_number_digits = 3

    define_method :add_node do
      |node, dry_run, verbose, escape_path, error, info|

      res = false
      begin
        greatest, extern_h = greatest_node_integer_and_externals
        int = greatest
        loop do
          int += 1
          if extern_h[ int ]
            info[ "avoiding confusing number collision #{
            }with #{ extern_h[int] }" ]
          else
            break
          end
        end
        identifier = "%0#{ node_number_digits }d" % int
        lines = ["[##{ identifier }] #{ node.first_line_body }"]
        lines.concat node.extra_lines
        res = add_lines_to_top lines, dry_run, escape_path, verbose,
          error, info
        break if ! res
        info[ "done." ]
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

    define_method :add_lines_to_top do
      |lines, dry_run, escape_path, verbose, error, info|

      res = false
      begin
        fail "implement me - create file" if ! pathname.exist?
        fu = self.fu escape_path, verbose, info
        tmpdir_pathname = self.tmpdir_pathname dry_run, fu, error
        break if ! tmpdir_pathname
        tmpold = tmpdir_pathname.join 'issues-prev.md'
        tmpnew = tmpdir_pathname.join 'issues-next.md'
        if tmpnew.exist?
          fu.rm tmpnew, noop: dry_run
        end
        write = -> fh do
          s = 's' if 1 == lines.length
          if lines.length.nonzero?
            if lines.length == 1
              info[ "new line: #{ lines[0] }" ]
            else
              info[ "new lines:" ]
              many = true
            end
          end
          lines.each do |l|                    # ~ put the newlines at the top ~
            info[ l ] if many
            fh.puts l
          end
          file.normalized_lines.each do |lin|  # #open-filehandle
            fh.puts lin                        # (but tested quite well)
          end
        end
        if dry_run
          write[ dev_null ]                    # sneaky
        else
          tmpnew.open( 'w+' ) do |fh|
            write[ fh ]
          end
        end
        if tmpold.exist?
          fu.rm tmpold, noop: dry_run
        end
        fu.mv pathname, tmpold, noop: dry_run
        fu.mv tmpnew, pathname, noop: dry_run
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

                                               # Using a hacky regex, scan
    def fu escape_path, verbose, info          # all messages emitted
      rx = Headless::CLI::PathTools::FUN.absolute_path_hack_rx
      fu = Headless::IO::FU.new( -> str do     # from the file utils client,
        s = str.gsub( rx ) do                  # and run everything that looks
          escape_path[ $~[0] ]                 # like an absolute path thru
        end                                    # the `escape_path` implemen.
        info[ s ] if verbose                   # *of the modality client*
      end )                                    # In turn, emit this messages
      fu                                       # as info to the same client.
    end

    def greatest_node_integer_and_externals
      enum = build_enum nil, nil, nil
      enum = enum.valid
      h = { }
      greatest = enum.reduce( -1 ) do |m, node|
        if node.prefix
          h[ node.integer ] = "[##{ node.prefix }-#{ node.identifier_string }]"
          m
        else
          x = node.integer
          m > x ? m : x
        end
      end
      [ greatest, h ]
    end

    def tmpdir_pathname dry_run, fu, error
      res = false
      begin
        break( res = @tmpdir_pathname ) if @tmpdir_pathname
        pn = ::Skylab::TMPDIR_PATHNAME.join 'snag-PROD' # heh
        if ! pn.dirname.exist?
          error and error[ "won't create more than one directory. #{
            }Parent directory of our tmpdir (#{ pn.basename }) must exist: #{
            }#{ escape_path pn.dirname }" ]
          break
        end
        if ! pn.exist?
          fu.mkdir( pn, noop: dry_run )
        end
        res = @tmpdir_pathname = pn
      end while nil
      res
    end
  end
end
