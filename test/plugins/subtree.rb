module Skylab::Test

  # `Subtree` plugin - experimentally, this is more like an "extension".
  # this whole app is basically useless without it, but we put it down
  # here as an exercize in compartmentalization. `Subtree` manages determining
  # the tree of tests to run, and paring down the tree with any options
  # provided.  (in fact, `Subtree` itself will have plugin modules that
  # themselves provide different such options.)

  module Plugins::Subtree

    Headless::Plugin.enhance self do
      eventpoints %i|
        available_options
        argument_list
        ready
        conclude
      |

      service_names %i|
        infostream
        info_y
      |

      plugin_services %i|
        hot_spec_paths
        hot_subtree
      |
    end
  end

  class Plugins::Subtree::Client

    # this is becoming more of a heavily relied-upon extension than just
    # # (more of a heavily depended upon extension)

    Headless::Plugin::Host.enhance self do

      # LOOK - experimentally we are a plugin *and* a plugin host ("app")
      # we use abbreviated names when there is a symbol of the same name in
      # the parent (e.g `argument_list` up, `arg_list` here), to mitigate
      # only slightly a potentially confusing situation.

      plugin_box_module -> { Plugins::Subtree::Agent }

      eventpoints %i|
        arg_list
        available_options
        compile
        is_active_boolean_agent
        sort
        postvalidate
        conclude
      |

      service_names %i|
        sort_mutex
      |
    end

    include Host_InstanceMethods

    available_options do |o, ctx_a|
      ctx_a ||= [ ]
      ctx_a << self  # qualify names
      merge_options o, nil, ctx_a
      true  # maybe, maybe not important
    end

    argument_list do |argv|
      emit_eventpoint :arg_list, argv
      nil  # our
    end

    ready do |y|
      emit_eventpoint( :compile, y ).nonzero? || nil
    end

    conclude do |y|
      emit_eventpoint( :conclude, y ).nonzero? || nil
    end

    def initialize( * )
      super
      @sort_mutex = nil
    end

    # ~ in vaguely narrative pre-order with occasional aesthetic pyramiding ~
    # ~ from the simplest of upstream targets: `files` ~

    # `hot_spec_paths` - implement the (plugin) service that is kind of
    # the central workhorse of this whole nerk.

    def hot_spec_paths
      ::Enumerator.new do |y|
        hot_subtree.flatten.each do |x|
          y << x
        end
      end
    end

    # `hot_subtree` - both a service and used internally

    def hot_subtree
      Headless::Services::Basic::Tree.new do |y|
        conflict_a = nil
        ag = build_aggregated_agent nil, -> do
          true
        end, -> confl_data do
          ( conflict_a ||= [ ] ) << confl_data
          false
        end
        sp_cache_a = [ ]
        all_subproducts.each do |sp|
          a = nil
          sp.all_spec_paths.each do |pn|
            ag.if_pass sp, pn, -> do
              ( a ||= [ ] ) << pn
              true
            end or break
          end
          conflict_a and break
          sp_cache_a << [ sp, a ]
        end
        r = -> do
          conflict_a and break report_conflicts( conflict_a )
          children_sort( sp_cache_a ) or break false
          postvalidate_children or break false
          true
        end.call
        if r
          sp_cache_a.each do |sp, a|
            y << ( Headless::Services::Basic::Tree.new sp do |yy|
              a.each( & yy.method( :<< ) ) if a
            end )
          end
          r
        end
        r
      end
    end
    protected :hot_subtree

    -> do  # `all_subproducts`

      white_rx = /\A[-a-z0-9]+\z/

      define_method :all_subproducts do
        ::Enumerator.new do |y|
          pn_a = ::Pathname.glob "#{ ::Skylab.dir_pathname }/*"
          pn_a.each do |pn|
            slug_s = pn.basename.to_s
            if white_rx =~ slug_s
              y << Plugins::Subtree::Subproduct_.new( slug_s, pn )
            end
          end
          nil
        end
      end
    end.call
    protected :all_subproducts

    def build_aggregated_agent( *func_a )
      a = [ ]
      emit_eventpoint :is_active_boolean_agent do |ea|
        ea.each do |_, agent|  # we can't map(& :last ) b.c ..
          a << agent
        end
      end
      Agent_::And_.new a, *func_a
    end

    module Agent_

    end

    class Agent_::And_

      class Pass_
        def pass *_
          :yes
        end
      end

      PASS_ = Pass_.new

      def initialize a, yes=nil, no=nil, conflict=nil
        @yes, @no, @conflict = yes, no, conflict
        @a = if a.length.zero?
          [ PASS_ ]
        else
          a.dup
        end
      end

      def if_pass sp, pn, yes=nil, no=nil, conflict=nil
        confl_a = nil
        res = agt = nil
        @a.each do |ag|
          r = ag.pass sp, pn
          r or fail "fix the below logic if you have a `nil` pass response."
          if res
            if res != r
              ( confl_a ||= [ ] ) << [ ag, r ]
              break  # for now
            end
          else
            res = r
            agt = ag
          end
        end
        if confl_a
          ( conflict || @conflict ).call(
            [ sp, pn, confl_a.unshift( [ agt, res ] ) ]
          )
        elsif :yes === res
          ( yes || @yes ).call
        elsif :no == res
          ( no || @no ).call
        else
          raise "agent `pass` result was invalid ( #{ r.inspect } from #{
            }#{ ag.to_s })"
        end
      end
    end

    def report_conflicts conflict_a
      y = host.info_y
      y << "your search terms didn't make sense to me -"
      conflict_a.each do |sp, pn, confl_a|
        ag_a = [ ] ; resp_a = [ ] ; detail_a = [ ]
        confl_a.each do |ag, resp|
          ag_a << ag.identify
          resp_a << resp
          detail_a << ag.detail_np
        end

        path = pn.relative_path_from( sp.dir_pathname ).to_s

        str_a = [ ]
        str_a << "confused about what to do with \"#{ sp.slug }\"'s #{
          }spec \"#{ path }\" -"

        n = confl_a.length
        str_a << "#{ ( ( n.times.reduce [] do |m, x|
          m << " #{ ag_a.fetch x } must have #{ detail_a.fetch x }"
          m
        end ) * ', while' ) }."

        str_a << " with this spec (\"#{ path }\"),"

        str_a << " #{ ( ( n.times.reduce [] do |m, x|
          m << "#{ ag_a.fetch x } said \"#{ resp_a.fetch x }\""
        end ) * ' and ' ) }"

        y << "#{ str_a * '' }. WAT DO"
      end
      false  # important - becomes `did_run` for some
    end

    def sort_mutex owner_name, if_yes, if_no
      if @sort_mutex
        if_no[ @sort_mutex ]
      else
        @sort_mutex = owner_name
        if_yes[ ]
      end
    end

    def children_sort sp_cache_a
      _emit_to_children :sort, sp_cache_a
    end

    def postvalidate_children
      _emit_to_children :postvalidate
    end

    def _emit_to_children eventpoint_i, * arg_a
      ok = true ; info_y = host.info_y
      emit_eventpoint_to_each_client eventpoint_i do |client|
        ok_y = ::Enumerator::Yielder.new do |msg|
          info_y << "#{ client.plugin_slug } plugin #{ msg }"
        end
        no_y = ::Enumerator::Yielder.new do |msg|
          ok = false
          info_y << "#{ client.plugin_slug } plugin #{ msg }"
        end
        [ *arg_a, ok_y, no_y ]
      end
      ok or info_y << "won't procede further because of the above."
      ok
    end
    private :_emit_to_children
  end

  class Plugins::Subtree::Subproduct_

    def initialize slug, dir_pathname
      @dir_pathname = dir_pathname
      @normalized_local_name = slug.intern
    end

    attr_reader :normalized_local_name, :dir_pathname

    def slug
      @slug ||= @normalized_local_name.to_s
    end

    -> do  # `all_spec_paths`
      spec_paths_cache = nil
      define_method :all_spec_paths do
        spec_paths_cache[ @normalized_local_name ]
      end

      cache_h = build_cache_h = nil ; empty_a = [ ].freeze  # ocd
      spec_paths_cache = -> norm do
        cache_h ||= build_cache_h[ ]
        cache_h.fetch norm do empty_a end
      end

      rx = %r|\G[-a-z0-9]+(?=/)|
      build_cache_h = -> do
        require 'skylab/test-support/fun'
        # #todo:during:5
        a = ::Pathname.glob ::Skylab.dir_pathname.join(
          "*/test/**/*#{ ::Skylab::TestSupport::FUN._spec_rb[] }" )
        offset = ::Skylab.dir_pathname.to_s.length + 1
        prev = oa = nil
        a.reduce( { } ) do |h, pn|
          md = rx.match( pn.to_s, offset ) or fail "wat - #{ pn }"
          slug = md[0].intern
          if prev != slug
            oa.freeze if oa
            prev = slug
            h[ slug ] = ( oa = [ ] )
          end
          oa << pn
          h
        end
      end
    end.call
  end

  module Plugins::Subtree  # (re-open)

    # (for local readability we break the indentation convention .. maybe
    # this means it's time for a separate file!)

    class Agent
      # search agents classes go here

      def identify
        "#{ plugin_slug } agent"
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

    class Agent::Black < Agent

      # blacklist-based filtering  ( `--not <subproduct>` )

      Headless::Plugin.enhance self do
        eventpoints %i|
          available_options
          is_active_boolean_agent
          compile
          postvalidate
          conclude
        |
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
      protected :activate

      def activate_verbose
        @be_verbose = true
        @ignored_spec_count = 0
      end
      protected :activate_verbose

      compile do |y|
        if @is_hot
          @pool_set = Headless::Services::Set[ * @str_a ]
          @length = @str_a.length
          true
        end
      end

      is_active_boolean_agent do

        # as an agent, you are hot iff the `--not` option was used

        @is_hot
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

    class Agent::White < Agent

      # whitelist-based filtering via subrpdocut name ( <sub1> <sub2> [..] )

      Headless::Plugin.enhance self do
        eventpoints %i|
          available_options
          arg_list
          compile
          is_active_boolean_agent
          postvalidate
          conclude
        |
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
      protected :activate

      compile do |y|
        _compile y if @is_hot  # because compile is called whether hot or not
      end

      def _compile y
        @str_a.freeze
        @length = @str_a.length
        @rx_a = @str_a.map { |s| %r{\A#{ ::Regexp.escape s }} }.freeze
        @cache_h = { }
        @pool_set = Headless::Services::Set[ * @str_a ]
        if @be_verbose
          @ignore_name_a = [ ]
          @ignore_count_h = ::Hash.new do |h, k|
            h[ k ] = 0
          end
        end
        nil
      end
      protected :_compile

      is_active_boolean_agent do

        # as an agent, you are hot iff you received the `arglist` eventpoint
        # (hence for which there was a nonzero-length list of arguments).

        @is_hot
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

    class Agent::Substring < Agent

      # pattern-based whitelisting

      include CLI::SubClient::InstanceMethods

      def initialize
        @is_hot = nil
      end

      Headless::Plugin.enhance self do
        eventpoints %i|
          available_options
          compile
          is_active_boolean_agent
          conclude
        |
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
      protected :activate

      compile do |y|
        @be_verbose ||= nil
        @skipped_spec_count = 0 if @be_verbose
        nil
      end

      is_active_boolean_agent do
        # as an agent, you are hot iff you processed any options
        @is_hot
      end

      # `pass` - see parent class

      def pass sp, pn
        str = pretty_path( pn ).to_s
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
  end

  class Plugins::Subtree::Agent::Order

    # (just for fun we do this as a standalone class, to grease it)

    Headless::Plugin.enhance self do
      eventpoints %i|
        available_options
        compile
        sort
        conclude
      |

      service_names %i|
        sort_mutex
      |
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
        host.sort_mutex '--first / --then', -> do
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
    protected :_sort
  end

  class Plugins::Subtree::Agent::Randomize

    Headless::Plugin.enhance self do
      eventpoints %i|
        available_options
        compile
        sort
        conclude
      |

      service_names %i|
        sort_mutex
      |
    end

    def initialize
      @be_verbose = nil
      @is_invoked = @do_random = @do_use_seed = nil
      @a = [ ]
    end

    available_options do |o, _|
      o.on '--order TYPE[:SEED]', 'yup. try --order random (imitate rspec)' do |x|
        @a << [ :order, x ]
      end
      o.on '--seed SEED', '(imitate rspec)' do |x|
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
        host.sort_mutex '--order random', -> do
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
