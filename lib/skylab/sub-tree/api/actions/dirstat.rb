module Skylab::CovTree

  class API::Actions::Dirstat

    def self.get_desc

      "the point of this one-off-ish is to show for a given changeset\n#{
        }how much changes are in which subproducts. but it has #{
        }generalized out from that.."

    end

    Money_ = -> sin, sout, serr, argv, program_name do
    # lose 2

  no = 1 ; yes = 0  # exit statii

  pn = -> { program_name }  # ui ..

  y = ::Enumerator::Yielder.new do |msg|
    serr.puts msg
    nil
  end

  clr = sin.tty? ? ( -> s do "\e[32m#{ s }\e[0m" end ) : -> s { s }

  invite = -> msg do
    y << msg
    y << "see '#{ pn[] } --help'"
    [ false, no ]
  end

  help = -> do
    y << "usage: #{ pn[] } <prefix> <file>"
    y << "   or: <git-command> | #{ pn[] } <prefix>"
    y << ''
    y << "typical usage:"
    y << "    #{ clr[ "git diff --numstat HEAD~1 | #{ pn[] } lib/skylab" ] }"
    [ false, yes ]
  end

  prefix, instream = -> do  # resolve these or do standard ui things
    case argv.length
    when 0
      break invite[ "missing argument: <prefix>" ]
    when 1
      /\A-(?:h|-help)\z/ =~ argv.fetch( 0 ) and break help[]
      sin.tty? and break invite[ "when no <file> argument provided, #{
        }expecting input from non-interactive terminal (pipe)." ]
      [ argv.fetch( 0 ), sin ]
    when 2
      sin.tty? or break invite[ "when <file> provided, must be run from #{
        }interactive terminal." ]
      [ argv.fetch( 0 ), ::File.open( argv.fetch( 1 ), 'r' ) ]
    else
      invite[ "too many arguments (#{ argv.length }) - expecting 1..2" ]
    end
  end.call
  prefix or break instream  # abuse - result was a standard result tuple.

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
    if true  # if we ever make lipstick an option
      begin
        CovTree::Services::Ncurses.class # # below
        nc_ok = true
      rescue ::LoadError
      end
    end
    if ! nc_ok then -> _ { } else
      CovTree::Services::Face.class  # #todo:during:0-subsystem, and above
      sp = '  '
      f = -> do
        tbl_width = ( fmt % [ 0, 0.0, '', ''] ).length
        ::Skylab::Face::CLI::Lipstick.new([[ '+', :green ], [ '-', :red  ]]).
          instance.cook_rendering_proc( [ tbl_width ], nil, sp.length )
          # (if you want it to be `git diff --stat`-like, change `nil` to `80`)
      end.call
      -> node do
        "#{ sp }#{ f[ lipfactor * node.added, lipfactor * node.removed ] }"
      end
    end
  end.call

  bucket_a.each do |node|
    sout.puts ( fmt %
      [ node.total, ( factor * node.total ), node.label, stk[ node ] ] )
  end
  y << "done."
  instream.close  # whether stdin or filehandle, there is always 1 open stream

  yes

    # gain 2
    end

    MetaHell::FUN.fields[ self, * Money_.parameters.map( & :last ) ]

    def execute
      Money_[ @sin, @sout, @serr, @argv, @program_name ]
    end
  end
end
