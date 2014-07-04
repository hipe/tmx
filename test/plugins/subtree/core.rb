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

    Plugin_.enhance self do  # LOOK - see below

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

  class Plugins::Subtree::Services__

    def initialize p
      @p = p
    end

    def any_test_pn_a_for_subproject_i i
      @p[ i ]
    end
  end

  class Plugins::Subtree::Client

    Plugin_::Host.enhance self do

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

    def services
      @services ||= Plugins::Subtree::Services__.new any_test_pn_a_for_subproject_i_p
    end

    include Merge_Options_

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

    def initialize( * )
      super
      @sort_mtx = Lib_::Basic_Mutex[]::Write_Once.new
    end

  private

    def any_test_pn_a_for_subproject_i_p
      subproject_cache.any_test_pn_a_for_subproject_i_p
    end

    def all_subproducts
      subproject_cache.all_subproject_a
    end

    def subproject_cache
      @subproject_cache ||= Subtree::Subproject_Cache_.new project_hub_pathname
    end

    def project_hub_pathname  # hardcoded currently but we would like for this
      ::Skylab.dir_pathname   # to be mutable so it could be used for strange
    end                       # projects, but that will require design.

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
      Lib_::Basic_Tree[].new do |y|
        conflict_a = nil
        ag = build_aggregated_agent nil, -> do
          true
        end, -> confl_data do
          ( conflict_a ||= [ ] ) << confl_data
          false
        end
        sp_cache_a = [ ]
        all_subproducts.each do |sp|
          nil_or_a = sp.some_test_paths.reduce nil do |m, pn|
            ag.if_pass sp, pn, -> do
              ( m ||= [ ] ) << pn
              true
            end or break( m )  # short circuit when `conflict_a` touched
            m
          end
          conflict_a and break
          sp_cache_a << [ sp, nil_or_a ]
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
            y << ( Lib_::Basic_Tree[].new sp do |yy|
              a.each( & yy.method( :<< ) ) if a
            end )
          end
          r
        end
        r
      end
    end

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
            iy << Test::Lib_::Reparenthesize[ say, msg ]
          end,
          ::Enumerator::Yielder.new do |msg|
            ok = false
            iy << say[ msg ]
          end ]
      end
      ok or iy << "won't procede further because of the above."
      ok
    end

    Subtree = Plugins::Subtree
  end

  module Plugins::Subtree

    class Subproject_Cache_  # wrap this up: we get the full tree via two
      # filesystem hits exposed by two respective surface members neither
      # of which is prerequisite for the other: 1) we will glob only once
      # for *all* test paths in the whole project, even if those for only
      # one subproject are requested; behind the rationale that the extra
      # filesystem overhead is neglible, and hopefully the extra storage/
      # construction overhead too (with our big hash), with the rationale
      # in turn that in practice we more often do operations accross sub-
      # project boundaries than within any one subproject. the second hit
      # is to glob for all the subproject dirs (& here is the main point)
      # which is necessary in addition to the first hit when one wants to
      # reveal all subproject names including those with no tests in them

      def initialize project_hub_pathname
        @project_hub_pn = project_hub_pathname
      end

      def all_subproject_a
        @all_subproject_a ||= get_subproject_a.freeze
      end

      def any_test_pn_a_for_subproject_i_p
        @p ||= build_p
      end

    private

      def get_subproject_a  # 2 dimensional "get" (in the ObjectiveC sense)
        p = any_test_pn_a_for_subproject_i_p ; ppn = @project_hub_pn
        all_subproject_i_a.map do |dir_i|
          Plugins::Subtree::Subproduct_.new ppn, p, dir_i
        end
      end

      def all_subproject_i_a
        @all_subproject_i_a ||= bld_all_subp_i_a
      end

      def bld_all_subp_i_a
        ::Pathname.glob( "#{ @project_hub_pn }/*" ).reduce( [] ) do |m, pn|
          WHITE_RX_ =~ (( stem_s = pn.basename.to_s )) or next m
          m << stem_s.intern
        end.freeze
      end
      #
      WHITE_RX_ = /\A[-a-z0-9]+\z/

      def build_p
        hublen = (( hub_pn = @project_hub_pn )).to_s.length + 1
        ::Pathname.glob( hub_pn.join(
          "*/#{ UNIVERSAL_TEST_DIR_RELPATH_ }/**/*#{ Test::Lib_::Spec_rb[] }"
        )).group_by do |pn|
          FIRST_DIR_RX_.match( pn.to_s, hublen ).to_s.intern
        end.method :[]
      end
      #
      FIRST_DIR_RX_ = %r|\G[-a-z0-9]+(?=/)|
    end

    class Subproduct_

      def initialize project_hub_pn, any_test_pn_a_p, dir_i
        @any_test_pn_a_p = any_test_pn_a_p
        @local_normal_name = dir_i
        @dir_pathname = project_hub_pn.join dir_i.to_s
      end

      attr_reader :local_normal_name, :dir_pathname

      def slug
        @slug ||= @local_normal_name.to_s
      end

      def test_dir_pn
        @test_dir_pn ||= @dir_pathname.join UNIVERSAL_TEST_DIR_RELPATH_
      end

      def any_test_pn_a
        @any_test_pn_a_p[ @local_normal_name ]
      end

      def some_test_paths
        any_test_pn_a || EMPTY_A_
      end
    end
  end
end
