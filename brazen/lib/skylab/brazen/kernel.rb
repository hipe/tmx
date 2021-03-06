module Skylab::Brazen

class Kernel  # [#015]

  def initialize mod=nil

    @module = mod

    yield self if block_given?

    @_name_function = nil
    @reactive_tree_seed ||= mod.const_get :Models_, false
  end

  attr_reader(
    :fast_lookup,
    :module,
    :reactive_tree_seed,
  )

  attr_writer(
    :fast_lookup,
    :module,
    :reactive_tree_seed,
  )

  # ~ call exposures

  def call * x_a, & x_p

    bc = bound_call_via_mutable_iambic x_a, & x_p
    bc and bc.receiver.send bc.method_name, * bc.args, & bc.block
  end

  def bound_call_via_mutable_iambic x_a, & p

    o = Home_::Actionesque_ProduceBoundCall.new self, & p
    o.iambic = x_a
    o.module = @module
    o.execute
  end

  def call_via_mutable_box * i_a, bx, & x_p  # [sg]

    bc = bound_call_via_mutable_box i_a, bx, & x_p

    bc and bc.receiver.send bc.method_name, * bc.args
  end

  def bound_call_via_mutable_box i_a, bx, & x_p  # [bs] only so far

    o = Home_::Actionesque_ProduceBoundCall.new self, & x_p
    o.iambic = i_a
    o.mutable_box = bx
    o.execute
  end

  def bound_call_via_argument_scanner scn, & x_p

    o = Home_::Actionesque_ProduceBoundCall.new self, & x_p
    o.argument_scanner = scn
    o.execute
  end

  # ~ general client exposures

  def description_proc
    NIL_  # etc
  end

  def app_name_string

    if @_name_function
      @_name_function

    elsif @module.respond_to? :name_function
      @module.name_function

    else
      nf = Common_::Name.via_module @module
      @_name_function = nf
      nf
    end.as_human
  end

  def do_debug
    # true
  end

  def debug_IO
    Home_.lib_.system.IO.some_stderr_IO  # etc
  end

  # ~ silo production

  def register_silo_daemon x, sym

    _silos.register_silo_daemon__ x, sym
  end

  def silo sym, & x_p

    if Home_::Silo::CONSTISH_RX =~ sym

      # when it looks like a const, assume we don't have to separate it

      silo_via_normal_identifier [ sym ]
    else
      _silos.via_symbol sym, & x_p
    end
  end

  def silo_via_normal_identifier const_a

    _silos.via_normal_stream Scanner_[ const_a ]
  end

  def silo_via_normal_stream st

    _silos.via_normal_stream st
  end

  def silo_via_identifier id, & p

    _silos.via_identifier id, & p
  end

  def _silos
    @___silos ||= Home_::Silo::Collection.new @reactive_tree_seed, self
  end

  # ~ unbound resolution

  def build_unordered_selection_stream & x_p

    # used most importantly by "produce bound call"

    _unbounds_indexation.build_unordered_selection_stream( & x_p )
  end

  def build_unordered_real_stream & x_p

    # for silo selection

    _unbounds_indexation.build_unordered_real_stream( & x_p )
  end

  def unbound const_sym, & x_p
    unbound_via :const, const_sym, & x_p
  end

  def unbound_via * x_a, & x_p
    _unbounds_indexation.unbound_via_arglist x_a, & x_p
  end

  def _unbounds_indexation

    @___UI ||= Home_::Branchesque::Indexation.new @reactive_tree_seed
  end
end
end
