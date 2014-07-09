module Skylab::Snag

  class Models::ToDo
    # imagine that parts of this are frozen

    require_relative 'to-do/enumerator' # [#mh-035] preload bc toplevel exists

    attr_reader :full_source_line

    attr_reader :line_number

    attr_reader :line_number_string

    def message_body_string
      range :body
    end

    def one_line_summary # [#it-001] summarization might be nice here
      if @replacement_line and @ranges || parse
        @replacement_line[ @ranges.tag.begin .. -1 ]
      else
        message_body_string
      end
    end

    attr_reader :path

    def pathname
      if @pathname.nil?
        @pathname = @path ? ::Pathname.new( @path ) : false
      end
      @pathname
    end

    def post_tag_string
      if @ranges || parse
        @full_source_line[ @ranges.tag.end + 1 .. -1 ]
      end
    end

    def pre_comment_string
      range :precomment
    end

    def pre_tag_string
      if @ranges || parse
        r =  @ranges.precomment.begin .. @ranges.tag.begin - 1
        if r.count.nonzero?
          @full_source_line[ r ]
        end
      end
    end

    attr_accessor :replacement_line

    def tag_string
      range :tag
    end

  private

    define_method :initialize do
      |path, line_number_string, full_source_line, pattern|
      @path = path                # (order ivars {aesthet, isomorph}ically!)
      @pathname = nil
      @line_number_string = line_number_string
      @line_number = @line_number_string.to_i
      @full_source_line = full_source_line
      @pattern = pattern
      @ranges = nil
    end

    before_rx = last_pattern = todo_rx = nil

    regexes = -> pattern do
      last_pattern = pattern
      todo_rx = /#{ pattern.gsub( /\\[<>]/, '\b' ) }/ # TERRIBLE
      before_rx = /(?:(?!#{ todo_rx.source }).)*/
    end

    ranges_struct = ::Struct.new :precomment, :tag, :body

    rscn = scn = nil

    # given a `full_source_line` that looks like:
    #   "      # %todo we would love to have -1, -2 etc"
    # parse out ranges for:
    #   + `precomment` : the leading whitespace before the '#'
    #   + `body`       : the string from 'we' to 'etc'
    #
    # some of these ranges may be zero width so it is *crucial* that
    # you check `count` on the range because otherwise getting the
    # substring 0..-1 of a string may *not* be what you expect, depending
    # on what you expect!

    define_method :parse do
      fail 'sanity' if @ranges
      if last_pattern != @pattern
        regexes[ @pattern ]
      end
      ranges = ranges_struct.new
      rscn ||= Snag_::Library_::StringScanner.new ''
      scn  ||= Snag_::Library_::StringScanner.new ''
      scn.string = full_source_line
      ranges.precomment = -> do # we need to back up till
        scn.skip( before_rx ) or fail 'rx'      # before the '#' :(
        rscn.string = full_source_line[ 0, scn.pos ].reverse
        if ! rscn.skip_until( /#/ ) && '#' != scn.peek( 1 )
          fail 'rx' # covered - the tag's hash might have been a comment leader
        end
        0 .. rscn.string.length - rscn.pos - 1
      end.call
      # the beginning of the rest now looks like: '%todo '
      pos = scn.pos
      scn.skip( todo_rx ) or fail 'rx'
      ranges.tag = pos .. scn.pos - 1
      scn.skip( /[[:space:]]*/ )
      ranges.body = scn.pos .. scn.string.length - 1
      @ranges = ranges
      true
    end

    def range name
      if @ranges || parse
        r = @ranges[ name ]
        if r.count.nonzero?
          @full_source_line[ r ]
        end
      end
    end
  end
end
