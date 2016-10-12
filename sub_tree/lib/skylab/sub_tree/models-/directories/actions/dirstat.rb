module Skylab::SubTree

  Models_::Directories = ::Module.new  # assert creation, is registered stowaway

  module Models_::Directories

    Actions = ::Module.new

    class Actions::Ping < API.action_class_

      @is_promoted = true

      def produce_result

        kr = @kernel

        maybe_send_event :info, :expression, :ping do | y |
          y << "hello from #{ em kr.app_name }."
        end

        :hello_from_sub_tree
      end
    end

    class Actions::Dirstat < API.action_class_

      @is_promoted = true

      self.instance_description_proc = -> y do

        y <<

      "the point of this one-off-ish is to show for a given changeset\n#{
        }how much changes are in which subproducts. but it has #{
        }generalized out from that.."

      end

      Invoke___ = -> sin, sout, serr, program_name, prefix, mode_a do

      # <-

  no = 1 ; yes = 0  # exit statii

  pn = -> { program_name }  # ui ..

  y = ::Enumerator::Yielder.new do |msg|
    serr.puts msg
    nil
  end

  # _clr = sin.tty? ? ( -> s do "\e[32m#{ s }\e[0m" end ) : -> s { s }

  bork = -> msg do
    y << msg
    y << "see '#{ pn[] } --help'"
    false
  end

  mode_a ||= [ :stdin ]

  instream = -> i, x=nil do
    case i
    when :stdin
      sin.tty? and break bork[ "when no <file> argument provided, #{
        }expecting input from non-interactive terminal (pipe) #{
        }or -- arg" ]
      sin
    when :file
      sin.tty? or break bork[ "when <file> provided, must be run from #{
        }interactive terminal." ]
      ::File.open( file, 'r' )
    when :git_diff
      /\AHEAD(:?~(\d+))?\z/ =~ x or break bork[ "expecting HEAD[~<n>]#{
        }, had #{ x.inspect }" ]
      $~[1] or x = "HEAD~1"  # meh
      cmd = "git diff --numstat #{ x }"
      _, o, e, w = Home_::Library_::Open3.popen3 cmd
      es = w.value.exitstatus ; 0 == es or break bork[ "got exitstatus #{
        }#{ es } from command - #{ cmd }" ]
      err_s = e.read
      err_s.length.nonzero? and break bork[ "unexpected - #{ err_s }" ]
      o
    else
      fail "sanity - #{ i }?"
    end
  end.call( * mode_a )
  instream or break no  # abuse - result was a standard result tuple.

  in_rx = /\A(\d+)\t(\d+)\t(.+)\n?\z/

  bucket_rx = %r{(?<=\A#{ ::Regexp.escape prefix }/)[^/]+(?=/)}

  node_ = Class.new.class_exec do

    def initialize lbl
      @label = lbl
      @added = @removed = 0
    end

    attr_reader :label, :added, :removed

    def add added, removed
      @added += added
      @removed += removed
      nil
    end

    def total
      @added + @removed
    end

    self
  end

  skipped = node_.new '(other)'

  bucket_h = ::Hash.new do |h, k|
    h[ k ] = node_.new k
  end

  bucket = -> path, added, removed do
    if (( md = bucket_rx.match path ))
      bucket_h[ md[0] ].add added, removed
    else
      skipped.add added, removed
    end
  end

  while line = instream.gets
    added, removed, path = ( in_rx.match line ).captures  # meh
    added = added.to_i ; removed = removed.to_i
    bucket[ path, added, removed ]
  end

  bucket_a = bucket_h.values
  bucket_a << skipped if skipped.total.nonzero?
  bucket_a.sort_by! { |n| -1 * n.total }

  widest = 0

  max = bucket_a.fetch( 0 ).total

  lipfactor = 1.0 / max  # if max is 80 and you have 40, 40 becomes 0.50.

  factor = 100.0 / ( bucket_a.reduce 0 do |m, n|
    ( l = n.label.length ) > widest and widest = l  # sneak this in
    m + n.total
  end )

  fmt = "%#{ max.to_s.length }d %6.2f  %-#{ widest }s%s"  # (shh math is hard)

  stk = -> do
      sp = '  '
      p = -> do
        tbl_width = ( fmt % [ 0, 0.0, '', ''] ).length
        Home_.lib_.CLI_lipstick( [[ '+', :green ], [ '-', :red  ]] ).
          instance.cook_rendering_proc( [ tbl_width ], nil, sp.length )
          # (if you want it to be `git diff --stat`-like, change `nil` to `80`)
      end.call
      -> node do
        "#{ sp }#{ p[ lipfactor * node.added, lipfactor * node.removed ] }"
      end
  end.call

  bucket_a.each do |node|
    sout.puts ( fmt %
      [ node.total, ( factor * node.total ), node.label, stk[ node ] ] )
  end
  y << "done."
  instream.close  # whether stdin or filehandle, there is always 1 open stream

  yes

  # ->

      end
    end
  end
end
