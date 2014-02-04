module Skylab::Test::Plugins::Subtree

  include ::Skylab::Test
  Lib_ = Lib_
  Plugin_ = ::Skylab::Face::Plugin

  class Agent_
    # search agents classes go here

    def identify
      "#{ local_plugin_moniker } agent"
    end

    def nmz x  # `nmz` - centralize the rendering of a list of names
      "(#{ x.to_a * ', ' })"
    end
    private :nmz

    #         ~ instance methods that subclasses must define: ~

    # `pass` ( sp, pn ) - `sp` is a subproduct metadata, and `np` is an
    # absolute ::Pathname in that subproduct. result must be `:yes` or
    # `:no` indicating whether or not this spec file represented by `pn`
    # may pass or not, given the state of this filtering agent.

    # `detail_np` - each child must implement this. it will be used
    # when reporting conflicts, and possibly for its own internal
    # self-articulation.

  end

  Agents = ::Module.new

  class Agents::Black < Agent_

    # blacklist-based filtering  ( `--not <subproduct>` )

    Plugin_.enhance self do

      eventpoints_subscribed_to( * %i|
        available_options
        is_active_boolean_agent
        compile
        postvalidate
        conclude
      | )
    end

    def initialize
      @is_hot = nil
      @be_verbose = nil  # let it get turned on even when we aren't activated
    end

    available_options do |o, _|

      o.on '--not <sub-product>', 'skip this sub-product',
        "(can specified multiple. exact match norm'd subproduct name)" do |x|
          @is_hot or activate
          @skip_rx_a << %r{\A#{ ::Regexp.escape x }}
          @str_a << x  # (might just be for ancilliary use)
      end

      o.on '-v', '--verbose', 'report number of skipped files' do
        @be_verbose or activate_verbose
      end

      true  # ( it is the API standard to return non-nil if actions taken )
    end

    def activate
      @is_hot and fail "sanity - unexpected state transition"
      @is_hot = true
      @str_a = [ ]
      @skip_rx_a = [ ]
      @cache_h = { }
      @be_verbose ||= nil
      nil
    end

    def activate_verbose
      @be_verbose = true
      @ignored_spec_count = 0
    end

    compile do |y|
      if @is_hot
        @pool_set = Lib_::Set[][ * @str_a ]
        @length = @str_a.length
        true
      end
    end

    is_active_boolean_agent do |&y|

      # as an agent, you are hot iff the `--not` option was used

      y[ @is_hot ]
    end

    # `pass` - see parent class

    def pass sp, pn
      yn = @cache_h.fetch( sp.slug ) do |k|
        r = @length.times.reduce :yes do |m, idx|
          if @skip_rx_a.fetch( idx ) =~ k
            @pool_set.delete @str_a.fetch( idx )  # might repeat
            break :no
          end
          m
        end
        @cache_h[ k ] = r
      end
      if @be_verbose and :no == yn
        @ignored_spec_count += 1
      end
      yn
    end

    postvalidate do |ok_y, no_y|
      if @is_hot
        if @pool_set.length.nonzero?
          no_y << "couldn't find any subproduct with names like #{
            }#{ nmz @pool_set }"
        end
        nil
      end
    end

    conclude do |y|
      if @is_hot && @be_verbose
        y << "skipped #{ @ignored_spec_count } spec file(s) #{
          }that had #{ detail_np }"
        true
      end
    end

    # `detail_np` - see parent class

    def detail_np
      "a subproduct name not starting with #{
        ( @str_a.reduce nil do |m, x|
          m ||= [ ]
          m << "\"#{ x }\""
          m
        end or [ 'nothing' ] ) * ' or '
      }"
    end
  end

  class Agents::White < Agent_

    # whitelist-based filtering via subrpdocut name ( <sub1> <sub2> [..] )

    Plugin_.enhance self do

      eventpoints_subscribed_to( * %i|
        available_options
        arg_list
        compile
        is_active_boolean_agent
        default_sort
        postvalidate
        conclude
      | )

    end

    def initialize
      @is_hot = nil
    end

    available_options do |o, _|
      o.on '-v', '--verbose', 'show subproducts that were skipped' do
        @be_verbose = true
      end
      true  # because we have some
    end

    arg_list do |argv|
      if argv.length.zero?
        fail "sanity - `arg_list` eventpoint must fire only for non-zero len."
      else
        activate
        @str_a = argv.dup  # ( guess what this does : [ * argv ] )
        argv.clear
        true  # because we processed it
      end
    end

    def activate
      @is_hot and fail "sanity - unexpected state transition"
      @be_verbose ||= nil
      @is_hot = true
      nil
    end

    compile do |y|
      _compile y if @is_hot  # because compile is called whether hot or not
    end

    def _compile y
      @str_a.freeze
      @length = @str_a.length
      @rx_a = @str_a.map { |s| %r{\A#{ ::Regexp.escape s }} }.freeze
      @cache_h = { }
      @pool_set = Lib_::Set[][ * @str_a ]
      if @be_verbose
        @ignore_name_a = [ ]
        @ignore_count_h = ::Hash.new do |h, k|
          h[ k ] = 0
        end
      end
      nil
    end

    is_active_boolean_agent do |&y|

      # as an agent, you are hot iff you received the `arglist` eventpoint
      # (hence for which there was a nonzero-length list of arguments).

      y[ @is_hot ]
    end

    default_sort do |mtx, sp_a, info_y, fail_y|
      if @is_hot
        mtx.is_held and fail "sanity - don't emit the event when is held."
        mtx.try_hold '<whitelist>', -> { }, nil
        norm_a = @str_a.map( & :intern )  # we don't validate this as a
        # valid whitelist - that happens later.
        orig_order_a = sp_a.map do |(sp, _)|
          sp.local_normal_name
        end
        addme = norm_a.length
        sp_a.sort_by! do |(sp, _)|
          normal = sp.local_normal_name
          idx = norm_a.index normal
          if idx
            idx
          else
            orig_order_a.index( normal ) + addme
            # make nerks not in the lisk come after, but in same
            # (probably lexical) order (even tho they probably won't stay
            # there, since this is a whitelist, and they aren't on the list)
          end
        end
        info_y << "(ordered the subproducts in the provided order)"
      end
      nil
    end

    # `pass` - see parent class

    def pass sp, pn

      # (a whitelist (always?) starts with `no` and then discovers any `yes`)

      yn = @cache_h.fetch sp.slug do |slug|
        @cache_h[ slug ] = @length.times.reduce :no do |m, idx|
          if @rx_a.fetch( idx ) =~ slug
            @pool_set.delete @str_a.fetch( idx )
            break :yes
          end
          m
        end
      end

      if @be_verbose && :no == yn  # report stats about nodes ignored
        @ignore_count_h[ sp.slug ] += 1
      end

      yn
    end

    postvalidate do |ok_y, no_y|
      if @is_hot
        if @pool_set.length.nonzero?
          no_y << "didn't recognize this/these as subproduct names - #{
            }#{ nmz @pool_set }"
        end
      end
      nil
    end

    conclude do |y|
      if @is_hot && @be_verbose
        if @ignore_name_a.length.nonzero?
          first = true
          a = @ignore_name_a.reduce [] do |m, x|
            num = @ignore_count_h.fetch( x )
            if num.nonzero?
              if first
                m << "#{ x } (#{ num } file(s))"
                first = false
              else
                m << "#{ x } (#{ num })"
              end
            end
            m
          end
          y << "filtered out files from these subproducts - (#{
            }#{ a * ', ' })"
        else
          y << "filtered out no files."
        end
        true
      end
    end

    # `detail_np` - see parent class

    def detail_np
      "a subproduct name starting with #{
        @str_a.map { |x| "\"#{ x }\"" } * ' or '
      }"
    end
  end

  class Agents::Substring < Agent_

    # pattern-based whitelisting

    def initialize
      @is_hot = nil
    end

    Plugin_.enhance self do

      eventpoints_subscribed_to( * %i|
        available_options
        compile
        is_active_boolean_agent
        conclude
      | )

      services_used [ :pretty_path, :ivar ]

    end

    available_options do |o, _|

      o.on '-s', '--substring <substr>',
        "if present, only load spec files",
        "whose [pretty] name includes substr" do |s|
          @is_hot or activate  # it happens only here
          @substring_a << s
      end

      o.on '-v', '--verbose',
        'report details about skipped filenames' do
          @be_verbose = true
      end

      true  # we should follow the standard, even if result is ignored
    end

    def activate
      @is_hot = true
      @substring_a = [ ]
      nil
    end

    compile do |y|
      @be_verbose ||= nil
      @skipped_spec_count = 0 if @be_verbose
      nil
    end

    is_active_boolean_agent do |&y|
      # as an agent, you are hot iff you processed any options
      y[ @is_hot ]
    end

    # `pass` - see parent class

    def pass sp, pn
      str = @pretty_path[ pn ]
      ok = ! @substring_a.index do |s|
        ! str.include?( s )
      end
      if ok
        :yes
      else
        if @be_verbose
          @skipped_spec_count += 1
        end
        :no
      end
    end

    conclude do |y|
      if @be_verbose and @is_hot
        y << "skipped #{ @skipped_spec_count } spec file(s) without #{
          }#{ detail_np }"
      end
      true
    end

    # `detail_np` - see parent class

    def detail_np
      "a spec file pretty pathname that contains #{
        ( @substring_a.reduce [] do |m, x|
          m << "\"#{ x }\""
        end ) * ' and '
      }"
    end
  end

  class Agents::Order

    # (just for fun we do this as a standalone class, to grease it)

    Plugin_.enhance self do

      eventpoints_subscribed_to( * %i|
        available_options
        compile
        sort
        conclude
      | )

      services_used :sort_mutex

    end

    def initialize
      @sexp = @be_verbose = nil
    end

    available_options do |o, _|
      o.on '-f', '--first <name-frag>', 'run this one first' do |x|
        ( @sexp ||= [ ] ) << [ :first, x ]
      end

      o.on '-t', '--then <name-frag>', 'run these ones in this order' do |x|
        ( @sexp ||= [ ] ) << [ :then, x ]
      end

      o.on '-v', '--verbose', 'be verbose.' do
        @be_verbose = true
      end

      true
    end

    compile do |y|
      if @sexp
        ok = false
        sort_mutex '--first / --then', -> do
          ok = true
        end, -> other_str do
          y << "won't do --first / --then when #{ other_str }"
        end
        if ok
          bork = -> msg do
            y << "nonsensical ordering: #{ msg }"
          end
          x = @sexp.fetch( 0 ).fetch( 0 )
          x == :first or break bork[ "--#{ x } before --first? NEVER." ]
          wat = @sexp[ 1..-1 ].detect { |k,| :first == k }
          wat and break bork[ "did not come first: --first #{ wat.fetch 1 }" ]
        end
      end
      nil
    end

    conclude do |y|
      if @sexp && @be_verbose
        y << "surely did order it"
        true
      end
    end

    class Comp_Tuple_ < ::Array

      include ::Comparable

      def <=> other
        length.times.reduce 0 do |m, idx|
          x = self[ idx ]
          y = other[ idx ]
          if x.nil?
            if ! y.nil?
              break 1
            end # else stay
          elsif y.nil?
            break -1
          else
            c = x <=> y
            if ! c.zero?
              break c
            end
          end
          m
        end
      end
    end

    sort do |cache_a, ok_y, no_y|
      if @sexp
        _sort cache_a, ok_y, no_y
      end
    end

    def _sort cache_a, ok_y, no_y
      orig_h = { }
      cache_a.each_with_index do |(sp, _), idx|
        orig_h[ sp.slug ] = idx
      end
      rx_a = @sexp.map do |(_, val)|
        %r{\A#{ ::Regexp.escape val }}
      end
      pool_a = rx_a.length.times.to_a
      cache_a.sort_by! do |(sp, _)|
        slug = sp.slug
        res = if pool_a
          pool_a.each_with_index.reduce nil do |m, (ix, i)|
            if rx_a.fetch( ix ) =~ slug
              pool_a[ i ] = nil
              pool_a.compact!
              pool_a.length.zero? and pool_a = nil
              break Comp_Tuple_[ ix ]
            end
          end
        end
        res || Comp_Tuple_[ nil, orig_h.fetch( slug ) ]
      end
      if pool_a
        a = pool_a.map do |idx|
          "\"#{ @sexp.fetch( idx ).fetch( 1 ) }\""
        end
        no_y << "found no subproducts matching #{ a * ' or ' }"
        false
      end
    end
  end

  class Agents::Randomize

    Plugin_.enhance self do

      eventpoints_subscribed_to( * %i|
        available_options
        compile
        sort
        conclude
      | )

      services_used :sort_mutex

    end

    def initialize
      @be_verbose = nil
      @is_invoked = @do_random = @do_use_seed = nil
      @a = [ ]
    end

    available_options do |o, _|
      like_vendor = "(imitate r#{}spec)"
      o.on '--order TYPE[:SEED]',
          "yup. try --order random #{ like_vendor }" do |x|
        @a << [ :order, x ]
      end
      o.on '--seed SEED', like_vendor do |x|
        @a << [ :seed, x ]
      end
      o.on '-v', '--verbose', 'verbose output' do
        @be_verbose = true
      end

      true
    end

    compile do |y|
      if @a.length.nonzero?
        ok = false
        sort_mutex '--order random', -> do
          ok = true
        end, -> other do
          y << "won't do --order random when #{ other }"
        end
        if ok
          @is_invoked = true
          if 1 < @a.length
            y << "we only allow one --order or --seed option"
          else
            i, x = @a.shift
            send "_compile_#{ i }", y, x
          end
        end
      end
    end

    def _compile_order y, x
      md =
      /\A(?:default | (?<random>rand(?:om)? (?::(?<seed>.+))?))\z/x.
        match( x )
      if ! md then
        y << "--order is invalid - #{ x }"
      elsif md[:random]
        @do_random = true
        if md[:seed]
          _compile_seed y, md[:seed]
        end
      end
      nil
    end

    def _compile_seed y, x
      if /\A\d+\z/ =~ x
        @do_use_seed = true
        @seed_int = x.to_i
      else
        @do_random = false
        y << "cannot parse seed as integer - #{ x }"
      end
      nil
    end

    sort do |cache_a, ok_y, no_y|
      if @do_random  # it may have been invoked but asked for default order..
        _shuffle cache_a, ok_y, no_y
      end
    end

    def _shuffle cache_a, ok_y, _no_y
      seed = if @do_use_seed
        @seed_int
      else
        ( rand * 10 ** 10 ).to_i # a pseudorandom 10-digit integer
      end
      if @be_verbose || true
        pn = ::Skylab.tmpdir_pathname.join( 'last-random.number' )
        pn.open 'w' do |fh|
          fh.write "#{ seed }"
        end
        ok_y << "( using seed #{ seed } - wrote #{ pn } )"
      end
      cache_a.shuffle! random: ::Random.new( seed )
      nil
    end

    conclude do |y|
      if @do_random && @be_verbose
        y << "surely did randomize it"
        true
      end
    end
  end
end
