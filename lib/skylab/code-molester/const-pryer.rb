module Skylab::CodeMolester

  class Const_Pryer

    # this is an intense hack. it is an intense hack.
    # scan the first few lines of a file with a hand-written parser looking
    # for what is the first class or module defined in the file is, skipping
    # over any comments. if you're thinking you could do it with a regex,
    # you're thinking it wrong. also, all of this is wrong.
    #
    # (a lot of this has necessary vestigials from the treetop hack that
    # it originally was.)

    CodeMolester::Lib_::Basic_Fields[ :client, self, :method, :_FIXME_11_absrb,
      :field_i_a, [ :outfile_stem, :path, :inpath_p, :outdir_p ] ]

    def self.[] path_s
      new( :path, path_s ).get_nested_const_names
    end

    def initialize *a
      @inpathname = @path = @outpathname = @outpath = nil
      _FIXME_11_absrb( *a )
    end

    def get_nested_const_names

      # this implementation is a shameless & deferential tribute which, if
      # not obvious at first glance, is intended to symbolize the triumph
      # of the recursive buck stopping somewhere even if it perhaps doesn't
      # need to.  (i.e.: yes i know, and i'm considering it.)

      file = Lib_::List_scanner[ inpathname.open 'r' ]

      scn = nil ; set_scanner_to_line = -> line do
        if scn then scn.string = line else
          scn = Library_::StringScanner.new line
        end
        nil
      end
      errmsg = -> exp_s do
        "expected #{ exp_s } near #{ Inspct_[ scn.rest ] }"
      end
      fetch = -> rx do
        scn.scan( rx ) or raise errmsg[ rx.inspect ]
      end
      first = true
      memo_a = [ ] ; eat_one_or_more_parts = -> do
        first &&= false
        begin
          memo_a << fetch[ RT_CNST_NM_RX_ ].intern
        end while scn.scan( /::/ )
        nil
      end
      pushed_back = nil
      gets = -> do
        line = if pushed_back
          r = pushed_back ; pushed_back = nil ; r
        else
          file.gets
        end
        if line
          set_scanner_to_line[ line ]
          true
        end
      end
      if gets[]  # so bad ..
        did = false ; have = true
        while scn.skip( /[ \t]*require(_relative)?[ \t(]/ )
          did = true
          have = gets[] or break
        end
        if have
          pushed_back = scn.string
        end
      end
      while gets[]
        scn.skip SPACE_RX_
        scn.eos? and next
        part = scn.scan( /(?:module|class|grammar)(?=[ \t]+)/ )
        if ! part
          if first then raise errmsg[ 'module or class, e.g' ]
          else break end
        end
        scn.skip( /[ \t]+/ ) or fail "sanity - above"
        scn.skip( /::/ )  # fully qualified toplevel names meh
        eat_one_or_more_parts[]
        scn.skip SPACE_RX_
        scn.eos? or raise errmsg[ 'eos' ]
      end
      memo_a.length.nonzero? and memo_a
    end

    RT_CNST_NM_RX_ = /[A-Z][A-Za-z0-9_]*/

    RIGHT_CONSTANT_NAME_RX_ = /\A#{ RT_CNST_NM_RX_.source }\z/

    SPACE_RX_ = /[ \t]*(#.*)?\n?/

    CTX_LEN_ = 40  # heuristic

    Inspct_ = Lib_::Inspect_proc[].curry[ CTX_LEN_ ]

    T_MODULE_ = 'module'.freeze

    def inpath
      if @path.nil?
        @path = if inpathname
          @inpathname.to_s
        else false end
      end
      @path
    end
    alias_method :path, :inpath  # can be more readable when no outpaths

    def outpath
      if @outpath.nil?
        @outpath = if outpathname
          @outpathname.to_s
        else false end
      end
      @outpath ||= outpathname.to_s
    end

    def inpathname
      if @inpathname.nil?
        if @inpath_p
          @path and fail "sanity - possibly conflicting `path` and `inpath_p`"
          @path = @inpath_p[] || false
        end
        @inpathname = if @path
          ::Pathname.new @path
        else false end
      end
      @inpathname
    end

    def outpathname
      if @outpathname.nil?
        @outpathname = if @outfile_stem
          @outdir_p[].
            join "#{ @outfile_stem }#{ ::Skylab::Autoloader::EXTNAME }"
        else false end
      end
      @outpathname
    end
  end
end
