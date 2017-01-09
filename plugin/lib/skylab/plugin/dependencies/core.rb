module Skylab::Plugin

  class Dependencies  # :[#007] (see)

    def initialize * args_to_all, & x_p

      @_args_to_all = args_to_all
      @_block_to_all = x_p
      @_formals = []
      @_instances = []
    end

    def dup * args_to_all, & x_p

      otr = super( & nil )
      otr.__init_dup args_to_all, & x_p
      otr
    end

    def initialize_dup _
      # hello. (everthing must go)
      NIL_
    end

    def __init_dup args_to_all, & x_p

      @_args_to_all = args_to_all
      @_block_to_all = x_p

      @_formals = @_formals.dup  # [#.B]

      @_role_bx = @_role_bx.dup  # [#.C]

      # [#.D] we have to make a deep copy manually:

      bx1 = @_sub_bx
      bx2 = Common_::Box.new
      bx2.a_.replace bx1.a_

      h_ = bx2.h_
      bx1.h_.each_pair do | k, a |
        h_[ k ] = a.dup  # (an array of integers)
      end

      # [#.E]:

      @_instances = @_instances.map do | o |

        if o
          o.dup( * @_args_to_all, & @_block_to_all )
        end
      end

      # [#.F]:

      @__volatile__res = nil
      @__volatile__ses = nil

      NIL_
    end

    # ~ read role implementors, subscribers

    def [] sym

      had = true
      d = @_role_bx.h_.fetch sym do
        had = false
      end
      if had
        if d
          _touch_instance d
        end
      else
        raise Home_::ArgumentError, _say_strange_role( sym )
      end
    end

    def accept_by sym

      had = true
      a = @_sub_bx.h_.fetch sym do
        had = false
      end
      if had
        a.each do | d |
          yield _touch_instance d  # we are now ignoring results
        end
        NIL_
      else
        raise Home_::ArgumentError, _say_strange_channel( sym )
      end
    end

    def _touch_instance d
      o = @_instances[ d ]
      if ! o
        o = @_formals.fetch( d ).
          class_.new( * @_args_to_all, & @_block_to_all )
        @_instances[ d ] = o
      end
      o
    end

    # ~ mutators

    def emits= i_a

      bx = Common_::Box.new
      i_a.each do | sym |
        bx.add sym, []
      end
      @_sub_bx = bx
      i_a
    end

    def roles= i_a

      bx = Common_::Box.new
      i_a.each do | sym |
        bx.add sym, nil
      end
      bx.a_.freeze  # strange and fun
      @_role_bx = bx
      i_a
    end

    def index_dependencies_in_module mod

      mod.constants.each do | const |
        index_dependency mod.const_get( const, false )
      end
      NIL_
    end

    def index_dependency cls

      a = cls::ROLES
      if a && a.length.nonzero?

        d = _begin_formal cls
        h = _role_edit_session
        a.each do | sym |
          h[ sym ] = d
        end
      end

      a = cls::SUBSCRIPTIONS
      if a && a.length.nonzero?

        d ||= _begin_formal cls
        h = _subscription_edit_session
        a.each do | sym |
          h[ sym ].push d
        end
      end

      NIL_
    end

    def _begin_formal cls
      d = @_formals.length
      @_formals[ d ] = Dependency___.new cls
      d
    end

    ## ~~ add to subscriptions, mutate role implementors

    def touch_dynamic_dependency cls  # :[#.H] :+#experimental

      h = ( @__volatile__DD ||= __build_dynamic_dependency_cache )
      yes = nil

      h.fetch cls do
        yes = true
        h[ cls ] = true
      end

      if yes
        __add_dynamic_depdendency cls
      end
      NIL_
    end

    def __add_dynamic_depdendency cls

      d = @_formals.length
      @_formals[ d ] = NIL_  # SKETCHY

      o = cls.new( * @_args_to_all, & @_block_to_all )

      @_instances[ d ] = o

      a = o.roles
      if a && a.length.nonzero?

        h = _role_edit_session
        a.each do | sym |
          h[ sym ] = d
        end
      end

      a = o.subscriptions
      if a && a.length.nonzero?

        h = _subscription_edit_session
        a.each do | sym |
          h[ sym ].push d
        end
      end
      NIL_
    end

    def __build_dynamic_dependency_cache

      h = {}
      @_instances.each do | o |
        o or next
        h[ o.class ] = true
      end
      h
    end

    def touch_subscription sym, impl

      d = _some_dependency_offset_for_implementation_instance impl
      h = _subscription_edit_session
      a = h[ sym ]
      if ! a.include? d
        a.push d
      end
      NIL_
    end

    def add_subscriptions * sym_a, impl

      d = _some_dependency_offset_for_implementation_instance impl
      h = _subscription_edit_session

      sym_a.each do | sym |
        h[ sym ].push d
      end

      NIL_
    end

    def change_strategies * sym_a, impl

      d = _some_dependency_offset_for_implementation_instance impl

      h = _build_role_session

      h.when_collision = h.when_init

      sym_a.each do | sym |

        h[ sym ] = d
      end
      NIL_
    end

    ## ~~ support

    def _some_dependency_offset_for_implementation_instance impl_

      a = @_instances
      oid = impl_.object_id
      offset = a.length.times.detect do | d |

        impl = a.fetch d
        impl or next

        oid == impl.object_id
      end

      if offset
        offset
      else
        raise Home_::ArgumentError, self._TODO_say_not_and_owned_dependency( impl_ )
      end
    end

    def _role_edit_session
      @__volatile__res ||= _build_role_session
    end

    def _subscription_edit_session
      @__volatile__ses ||= __build_subscription_edit_session
    end

    def _build_role_session

      @_role_bx or fail __say_no_roles

      h = @_role_bx.h_
      o = Role_Edit_Session___.new

      o.when_collision = -> d_, d, sym do
        raise Home_::ArgumentError, __say_role_collision( d_, d, sym )
      end

      o.when_init = -> d_, d, sym do
        h[ sym ] = d_
        sym
      end

      o.when_strange_role = -> sym do
        raise Home_::ArgumentError, _say_strange_role( sym )
      end

      o.when_write = -> d_, sym do

        had = true
        d = h.fetch sym do
          had = false
        end

        if had
          if d
            o.when_collision[ d_, d, sym ]
          else
            o.when_init[ d_, d, sym ]
          end
        else
          o.when_strange_role[ sym ]
        end
      end

      o
    end

    class Role_Edit_Session___

      def []= k, x
        @when_write[ x, k ]
      end

      attr_accessor(
        :when_collision,
        :when_init,
        :when_strange_role,
        :when_write,
      )
    end

    def __build_subscription_edit_session

      @_sub_bx or fail __say_no_subs

      h = @_sub_bx.h_
      pxy = Subscription_Edit_Session___.new
      pxy.read_proc = -> sym do

        had = true
        a = h.fetch sym do
          had = false
        end
        if had
          a
        else
          raise Home_::ArgumentError, _say_strange_channel( sym )
        end
      end
      pxy
    end

    class Subscription_Edit_Session___

      attr_writer :read_proc

      def [] k
        @read_proc[ k ]
      end
    end

    ## ~~ say messages

    def __say_no_roles
      "did you forget to call `#roles=`?"
    end

    def __say_no_subs
      "did you forget to call `#emits=`?"
    end

    def __say_role_collision d_, d, sym

      _, __ = [ d, d_ ].map do | idx |

        @_formals[ idx ].class_.name
      end

      "role '#{ sym }' cannot be assumed by #{ __ }, it is #{
        }already assumed by #{ _ }"
    end

    def _say_strange_channel sym

      _ = Lev__[ sym, @_sub_bx.a_ ]
      "emission channel #{ _ }"
    end

    def _say_strange_role sym

      _ = Lev__[ sym, @_role_bx.a_ ]
      "role #{ _ }"
    end

    # ~ concerns & adjuncts

    def process_polymorphic_stream_fully st

      o = _build_arg_demux
      o.upstream = st
      o.execute
    end

    def process_polymorphic_stream_passively st

      o = _build_arg_demux
      o.be_passive = true
      o.upstream = st
      o.execute
    end

    def argument_bid_group_for tok

      Dependencies_::Argument::Bid_group[ tok, self ]
    end

    def _build_arg_demux

      o = Dependencies_::Argument::Demux.new
      o.pub_sub_dispatcher = self
      o
    end

    class Dependency___

      attr_reader(
        :class_,
      )

      def initialize cls

        @class_ = cls
        freeze  # we MUST do this per [#.A]
      end

      undef_method :dup
    end

    Definition_Conflict = ::Class.new ::RuntimeError


    Lev__ = -> x, a do

      Home_.lib_.basic::List::EN::Say_not_found[ 3, a, x ]
    end

    Dependencies_ = self
  end
end
