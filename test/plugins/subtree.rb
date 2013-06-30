module Skylab::Test

  # `Subtree` plugin - experimentally, this is more like an "extension"
  # (as it might be called in mozilla culture.) this whole app is basically
  # useless without it, but we put it down here as an exercize in
  # compartmentalization. other plugins may rely on this plugin without
  # knowing it (the not knowing it is important!).
  #
  # `Subtree` manages determining the tree of tests to run, and paring down
  # the tree with any options provided. (in fact, `Subtree` itself will have
  # plugin modules that themselves provide different such options! plugins
  # for plugons omg two levels! (relax it's just a tree))

  module Plugins::Subtree

    Headless::Plugin.enhance self do  # LOOK - see below

      eventpoints_subscribed_to( * %i|
        available_options
        argument_list
        ready
        conclude
      | )

      services_used [ :em, :ivar ],
        :infostream,
        :info_y,
        [ :pretty_path, :ivar ]
    end
  end

  class Plugins::Subtree::Client

    Headless::Plugin::Host.enhance self do

      # LOOK - experimentally we are a plugin *and* a plugin host ("app")
      # we use abbreviated names when there is a symbol of the same name in
      # the parent (e.g `argument_list` up, `arg_list` here), to mitigate
      # only slightly a potentially confusing situation.

      plugin_box_module -> { Plugins::Subtree::Agents }

      eventpoints( * %i|
        arg_list
        available_options
        compile
        is_active_boolean_agent
        sort
        default_sort
        postvalidate
        conclude
      | )

      services(
        :em,
        :sort_mutex,
        [ :pretty_path, :ivar ],
        :hot_spec_paths,
        [ :hot_subtree, :method, :hot_subtree_as_service ]
      )

    end

    include Host_InstanceMethods  # `merge_options`
    include Agent_IM_

    available_options do |op, ctx_a|
      ctx_a ||= [ ]
      ctx_a << self  # qualify names
      merge_options op, nil, ctx_a
      true  # maybe, maybe not important
    end

    argument_list do |argv|
      emit_eventpoint :arg_list, argv
      nil  # our
    end

    ready do |y|
      emit_eventpoint :compile, y
      nil
    end

    conclude do |y|
      emit_eventpoint :conclude, y
    end

  private

    # ~ in vaguely narrative pre-order with occasional aesthetic pyramiding ~
    # ~ from the simplest of upstream targets: `files` ~

    def initialize( * )
      super
      @sort_mtx = Headless::Services::Basic::Mutex.new
    end

    def hot_spec_paths
      # implement the (plugin) service that is kind of the central workhorse
      # of this whole nerk
      ::Enumerator.new do |y|
        __hot_subtree__.flatten.each do |x|
          y << x
        end
      end
    end

    def hot_subtree_as_service
      __hot_subtree__
    end

    def __hot_subtree__
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
          @sort_mtx.is_held or ( children_dflt_srt sp_cache_a or break false )
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

    def build_aggregated_agent * func_tuple
      y = [ ]
      emit_eventpoint :is_active_boolean_agent do |pi, bool|
        bool and y << pi
      end
      Plugins::Subtree::And_.new y, * func_tuple
    end

    def report_conflicts conflict_a
      y = info_y
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
      @sort_mtx.try_hold owner_name, if_yes, if_no
    end

    def children_sort sp_cache_a
      _emit_to_children :sort, sp_cache_a
    end

    def children_dflt_srt sp_cache_a  # assume ! @sort_mtx.is_held
      _emit_to_children :default_sort, @sort_mtx, sp_cache_a  # result is bool
    end

    def postvalidate_children
      _emit_to_children :postvalidate
    end

  private

    def _emit_to_children eventpoint_i, * arg_a
      iy = info_y ; ok = true
      emit_customized_eventpoint eventpoint_i, -> pi do
        say = -> msg do
          "#{ pi.local_plugin_moniker } plugin #{ msg }"
        end
        [ * arg_a,
          ::Enumerator::Yielder.new do |msg|
            iy << Face::CLI::FUN.reparenthesize[ msg, say ]
          end,
          ::Enumerator::Yielder.new do |msg|
            ok = false
            iy << say[ msg ]
          end ]
      end
      ok or iy << "won't procede further because of the above."
      ok
    end
  end

  class Plugins::Subtree::Subproduct_

    def initialize slug, dir_pathname
      @dir_pathname = dir_pathname
      @local_normal_name = slug.intern
    end

    attr_reader :local_normal_name, :dir_pathname

    def slug
      @slug ||= @local_normal_name.to_s
    end

    -> do  # `all_spec_paths`
      spec_paths_cache = nil
      define_method :all_spec_paths do
        spec_paths_cache[ @local_normal_name ]
      end

      cache_h = build_cache_h = nil ; empty_a = [ ].freeze  # ocd
      spec_paths_cache = -> norm do
        cache_h ||= build_cache_h[ ]
        cache_h.fetch norm do empty_a end
      end

      rx = %r|\G[-a-z0-9]+(?=/)|
      build_cache_h = -> do
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
end
