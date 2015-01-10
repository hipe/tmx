module Skylab::Basic

  module String

  class Template__  # see [#028]

    class << self

      def [] template_str, param_h
        via_string( template_str ).call param_h
      end

      def via_path path
        new :pathname, ( path ? ::Pathname.new( path.to_s ) : path )
      end

      def via_string string
        new :string, string
      end

      def string_has_parameter str, param_name
        str.include? parametize[ param_name ]
      end

      define_method :parametize, -> do
        p = -> s do
          "{{#{ s }}}"  # super duper non-robust for now
        end
        -> { p }
      end.call
    end

    member_i_a = [ :pathname, :string ]

    attr_reader( * member_i_a )

    MEMBER_I_A__ = member_i_a.freeze

    IVAR_H__ = ::Hash[ member_i_a.map { |i| [ i, :"@#{ i }" ] } ]

    DFLT_H__ = ::Hash[ member_i_a.map { |i| [ i, nil ] } ]

    def initialize * xx_a
      process_iambic_or_param_h_fully xx_a
    end
  private
    def process_iambic_or_param_h_fully xx_a
      if 1 == xx_a.length
        process_param_h_fully xx_a.first
      else
        absorb_iambic_fully xx_a
      end
    end

    def process_param_h_fully param_h

      i_a = param_h.keys - self.class::MEMBER_I_A__
      i_a.length.nonzero? and raise ::NameError, say_extra( i_a )

      ivar_h = self.class::IVAR_H__
      dflt_h = self.class::DFLT_H__.dup

      param_h.each do |i, x|
        dflt_h.delete i
        instance_variable_set ivar_h.fetch( i ), x
      end

      dflt_h.each do |i, x|
        instance_variable_set ivar_h.fetch( i ), x
      end ; nil
    end

    def absorb_iambic_fully x_a

      ivar_h = self.class::IVAR_H__
      dflt_h = self.class::DFLT_H__

      seen_h = {}
      x_a.each_slice 2 do |i, x|
        ivar = ivar_h[ i ]
        ivar or raise ::NameError, say_extra( [ i ] )
        seen_h[ i ] = true
        instance_variable_set ivar, x
      end

      ( dflt_h.keys - seen_h.keys ).each do |i|
        instance_variable_set ivar_h.fetch( i ), dflt_h.fetch( i )
      end ; nil
    end

    def say_extra i_a
      Basic_.lib_.NLP_EN_agent.calculate do
        "no member#{ s i_a } #{ or_( i_a.map { |x| "'#{ x }'" } ) } in struct"
      end
    end

  public

    def call param_h
      template_string.gsub( parameter_rx ) do
        param_i = normalize_matched_parameter_name $1
        had = true
        x = param_h.fetch param_i do
          had = false
        end
        if had
          x
        else
          parametize param_i
        end
      end
    end

    alias_method :[], :call

  private

    def parameter_rx
      Basic_::String.mustache_regexp
    end

    define_method :parametize, parametize

    # read #about-margins

    public def first_margin_for param_i
      margin_cache_h.fetch( param_i )._margin
    end

    def margin_cache_h
      @_margin_cache_h ||= bld_margin_cache_h
    end

    def bld_margin_cache_h
      h = {} ; scn = get_formal_parameters_scan :with_margin
      while param = scn.gets
        h[ param.local_normal_name ] = param
      end
      h
    end

  public

    def normalized_formal_parameter_names
      get_formal_parameters.map { |o| o.local_normal_name }
    end

    def get_formal_parameters with_margins=false  # #note-110
      get_formal_parameters_scan( with_margins ).each
    end

  private

    def get_formal_parameters_scan with_margins=false

      param_rx = parameter_rx  # hypothetically mutable ick

      skip_rx = /(?: (?! #{ param_rx.source } ) . )+/mx

      with_margins and marg = Margin_Engine__.new

      seen_h = {}

      scn = Basic_.lib_.string_scanner template_string

      Callback_.stream do
        while ! scn.eos?
          skipped_s = marg ? ( scn.scan skip_rx ) : ( scn.skip skip_rx )
          surface_s = scn.scan param_rx
          ( skipped_s || surface_s ) or fail say_parse_hack_failure
          surface_s or next
          _md = param_rx.match surface_s
          name_i = normalize_matched_parameter_name _md[ 1 ]
          seen_h[ name_i ] and next
          seen_h[ name_i ] = true
          marg and marg.take skipped_s
          offset = scn.pos - surface_s.length
          param = Param__[ surface_s, name_i, offset, marg && marg.give ]
          break
        end
        param
      end
    end

    Param__ = ::Struct.new :surface, :local_normal_name, :offset, :_margin do

      alias_method :name_i, :local_normal_name
    end

    Margin_Engine__ = Basic_.lib_.ivars_with_procs_as_methods.new :give, :take do

      def initialize

        is_fresh_line = true ; mgn = nil

        fresh_line = -> rpos, s do
          mgn = if rpos  # let margin be the empty string for the relevant params
            s[ rpos + 1 .. -1 ]
          else
            s
          end
          is_fresh_line = false ; nil
        end

        see = -> s do
          rpos = s.rindex NEWLINE_
          ! is_fresh_line and rpos and is_fresh_line = true
          is_fresh_line and fresh_line[ rpos, s ]
        end

        @take = -> s do
          mgn = nil  # allow for multiple takes with no give
          s and see[ s ]
          nil
        end

        @give = -> do
          x = mgn ; mgn = nil ; x
        end
      end

      NEWLINE_ = "\n".freeze

    end

    def normalize_matched_parameter_name x
      x.strip.intern
    end

    def say_parse_hack_failure
      # if it wasn't EOS then our logic must be wrong
      "sanity - parse hack failure"
    end

    def template_string
      if @string
        @string
      else
        @pathname.read
      end
    end
  end
  end
end
