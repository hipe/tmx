module Skylab::Brazen

class Kernel  # [#015]

  def initialize mod=nil

    @module = mod

    yield self if block_given?

    @_name_function = nil
    @source_for_unbounds ||= mod.const_get :Models_, false
  end

  attr_reader(
    :module,
    :source_for_unbounds,
  )

  attr_writer(
    :module,
    :source_for_unbounds,
  )

  # ~ call exposures

  def call * x_a, & x_p

    bc = bound_call_via_mutable_iambic x_a, & x_p
    bc and bc.receiver.send bc.method_name, * bc.args, & bc.block
  end

  def bound_call_via_mutable_iambic x_a, & oes_p

    o = Home_::Actionesque::Produce_Bound_Call.new self, & oes_p
    o.iambic = x_a
    o.module = @module
    o.execute
  end

  def call_via_mutable_box * i_a, bx, & x_p  # [sg]

    bc = bound_call_via_mutable_box i_a, bx, & x_p

    bc and bc.receiver.send bc.method_name, * bc.args
  end

  def bound_call_via_mutable_box i_a, bx, & x_p  # [bs] only so far

    o = Home_::Actionesque::Produce_Bound_Call.new self, & x_p
    o.iambic = i_a
    o.mutable_box = bx
    o.execute
  end

  def bound_call_via_polymorphic_stream arg_st, & x_p

    o = Home_::Actionesque::Produce_Bound_Call.new self, & x_p
    o.argument_stream = arg_st
    o.execute
  end

  # ~ general client exposures

  def app_name

    if @_name_function
      @_name_function

    elsif @module.respond_to? :name_function
      @module.name_function

    else
      nf = Callback_::Name.via_module @module
      @_name_function = nf
      nf
    end.as_human
  end

  def do_debug
    # true
  end

  def debug_IO
    LIB_.system.IO.some_stderr_IO  # etc
  end

  # ~ silo production

  const_rx = nil

  define_method :silo do | sym, & x_p |

    const_rx ||= /\A[A-Z]/
    if const_rx =~ sym
      silo_via_normal_identifier [ sym ]
    else
      _silos.via_symbol sym, & x_p
    end
  end

  def silo_via_normal_identifier const_a

    _silos.via_normal_stream( Callback_::Polymorphic_Stream.new( 0, const_a ) )
  end

  def silo_via_normal_stream st

    _silos.via_normal_stream st
  end

  def silo_via_identifier id, & oes_p

    _silos.via_identifier id, & oes_p
  end

  def _silos
    @__silos ||= Home_::Silo::Collection.new @source_for_unbounds, self
  end

  def init_silos unb_models
    @__silos = Home_::Silo::Collection.new unb_models, self
    yield @__silos
    NIL_
  end

  # ~ unbound resolution

  def fast_lookup
    NIL_  # not implemented here because with promotions it's not worth it
  end

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

    @___UI ||= Home_::Branchesque::Indexation.new @source_for_unbounds
  end
end
end
