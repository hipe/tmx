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
            info[ "manifest file didn't exist - no issues." ]
            break
            # (if pathname is resolved (i.e. we know what it *should* be)
            # and it doesn't exist, there are simply no issues.)
          end
          node_flyweight ||= Models::Node::Flyweight.new nil, pathname
          last_item = catch :last_item do
            node_flyweight.each_node file.normalized_line_producer, y
            nil
          end
          if last_item
            file.release_early
            throw :last_item, last_item
          end
          nil
        end while nil
      end
    end

    def add_node node, dry_run, verbose, escape_path, error, info
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
        res = edit_lines 0, render_lines( node, int ), dry_run, escape_path,
          verbose, error, info
        break if ! res
        info[ "done." ]
      end while nil
      res
    end

    def change_node node, dry_run, verbose, escape_path, error, info
      lines = render_lines node
      edit_lines node.identifier.render, lines, dry_run, escape_path,
        verbose, error, info
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

    change_lines = -> error, file, info, lines, rendered_identifier do
      -> fh do
        sep = nil
        write = -> lin do
          fh.write "#{ sep }#{ lin }"
          sep ||= "\n" # meh [#020]
          nil
        end
        res = nil
        found = false
        existing = file.normalized_line_producer
        line = existing.gets
        while line
          if 0 == line.index( rendered_identifier )
            found = true
            begin                 # discard old lines
              line = existing.gets
            end while line && /^[[:space:]]/ =~ line # eek
            lines.each do |new_line|
              write[ new_line ]
            end
          else
            write[ line ]
            line = existing.gets
          end
        end
        if found
          res = true
        else
          res = error[ "node lines not found for node with identifer #{
            }#{ rendered_identifier }" ]
        end
        res
      end
    end

    prepend_lines = -> file, info, lines do
      -> fh do
        if lines.length.nonzero?
          if lines.length == 1
            info[ "new line: #{ lines[0] }" ]
          else
            info[ "new lines:" ]
            many = true
          end
        end
        lines.each do |l|                      # ~ put the newlines at the top ~
          info[ l ] if many
          fh.puts l
        end
        file.normalized_lines.each do |lin|    # (#open-filehandle)
          fh.puts lin
        end
      end
    end

    class DevNull_                # hehe the sneaky hops we jump thru to get
      def puts *a                 # a good dry run. (class for sing. [#sl-126])
      end
      def write s
      end
    end

    dev_null = DevNull_.new

    # when `lines_ref` is zero it means "insert `lines` at the beginning"
    # else `lines_ref` is expected to be a rendered identifier, for which
    # `lines` will replace the existing lines for that node. `error` is
    # called when the node lines are not found for a `node_ref`.

    define_method :edit_lines do
      |lines_ref, lines, dry_run, escape_path, verbose, error, info|

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
        write = if 0 == lines_ref
          prepend_lines[ file, info, lines ]
        else
          change_lines[ error, file, info, lines, lines_ref ]
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
      @file ||= begin
        @pathname or fail 'sanity'
        Models::Node::File.new @pathname
      end
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
      prefixed_h = { }
      greatest = enum.reduce( -1 ) do |m, node|
        if node.identifier_prefix
          prefixed_h[ node.integer ] = Snag::Models::Identifier.render(
            node.identifier_prefix, node.identifier_body )
          m
        else
          x = node.integer
          m > x ? m : x
        end
      end
      [ greatest, prefixed_h ]
    end

    -> do

      id_num_digits = 3

      define_method :render_lines do |node, int=nil|
        rendered_identifier = if int
          Snag::Models::Identifier.create_rendered_string int, id_num_digits
        else
          node.rendered_identifier
        end
        lines = [ "#{ rendered_identifier } #{ node.first_line_body }" ]
        lines.concat node.extra_lines
        lines
      end

    end.call

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
