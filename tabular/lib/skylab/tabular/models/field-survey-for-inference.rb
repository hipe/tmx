module Skylab::Tabular

  Zerk_lib_[]

  class Models::FieldSurvey_for_Inference < Zerk_::CLI::Table::Models::FieldSurvey  # 1x

    # synopsis: gather statistical information (min, max) about fields
    # during the page survey, rather than through the use of field
    # observers.
    #
    #
    # justification
    #
    # to render (for example) a max-share column requires aggregative,
    # "vertically derived" information that pertains to the whole "column"
    # (for some definition of column); in this case the min and max numeric
    # values seen in the column (tracked here under [#ze-059.1]).
    #
    # normally a table design is defined statically, and then a stream of
    # page surveys is passed through the table design (in effect).
    # vertically derived values such as the min and max above are then
    # gathered through the use of the field-observer facility, which is
    # part of the (statically defined) design and is employed during the
    # page survey phase (such that every page feeds into the same shared
    # aggregation).
    #
    # under "infer table", however, we derive the table design *from* the
    # surveyed pages (one design per page). we don't know which columns we
    # will want to observe until the survey is over, and by then it is to
    # late to observe values as they are surveyed.
    #
    # rather than adding another pass to our pipeline just to solve for
    # "infer table", we solve this by injecting the subject into the survey
    # phase: we gather statistical information "optimistically" on the
    # first pass for every mixed cel that we read from the upstream (when
    # that cel ends up being numeric), regardless of whether the final field
    # (column) ends up being numeric.
    #
    # (note that any column could become a numeric column at any time based
    # on how `threshold_for_whether_a_column_is_numeric` works - you won't
    # be able to know whether the column is or isn't numeric until the end
    # of the survey.)
    #
    # it's unlikely, but you might ask why don't we just push this
    # functionality up into our field survey base class. the reason we don't
    # is one of design: it's bad style to cram special-interest needs into
    # our base class. instead we #exercise this field survey class
    # injection facility and field observer facility for inferred tables
    # and not, variously and respectively.
    #
    # (i.e it's better, less monolithic design not to.)

    # implementation notes:
    #
    # this is the kind of nasty, multi-tiered inheritance chain we try to
    # avoid but here it is: this is a triple-node inheritance chain.
    #
    # the reason we see this triple-node inheritance as allowable is that
    # there's a rigid, slot-like API these sublasses must fit into: they
    # should never add methods; only override existing methods and always
    # call `super` as the final expression of their definition.
    #
    # (NOTE no ivar name nor non-public method name is safe here. any one
    # could get clobbered by the parent class at any time. as a talisman
    # against this, we put the word "minmax" in every such name :( )
    #
    # these new classes add behavior, but the responsibility of the class
    # is never outside the scope of the original root node. in effect each
    # method definition amounts to the adding of a passive listener to one
    # of a fixed splay of possible events. (the intention of the [#ba-058]
    # "hook mesh" was to faciliate such a growable network of subscribers
    # but we find now that the plain old platform language feature of
    # inheritance accomplishes more or less the same objective without the
    # cost of an API to learn.)
    #
    # the topmost node surveys basic counts of the occurrences of the
    # different typeishes. our immediate parent surveys string-metrics
    # for the apriori inference of [#ze-050.A]. as for us, we gather
    # whatever statistical info we need for the local project.

    def initialize mesh
      @_see_minmax = :__see_first_minmax
      super NOTHING_, mesh  # (no defined field here)
    end

    def on_typeish_negative_nonzero_float f
      send @_see_minmax, f
      super
    end

    def on_typeish_negative_nonzero_integer d
      send @_see_minmax, d
      super
    end

    def on_typeish_positive_nonzero_float f
      send @_see_minmax, f
      super
    end

    def on_typeish_positive_nonzero_integer d
      send @_see_minmax, d
      super
    end

    def on_typeish_zero number
      send @_see_minmax, number
      super
    end

    def __see_first_minmax x
      @_minmax_min = x
      @_minmax_max = x
      @_see_minmax = :__see_minmax_normally
      @__read_minmax_min = :__read_minmax_min_normally
      @__read_minmax_max = :__read_minmax_max_normally
      NIL
    end

    def __see_minmax_normally x
      if @_minmax_max < x
        @_minmax_max = x
      elsif @_minmax_min > x
        @_minmax_min = x
      end
      NIL
    end

    def finish
      remove_instance_variable :@_see_minmax
      super
    end

    # -- read

    def minmax_min  # assumes at least one numeric in column
      send @__read_minmax_min
    end

    def minmax_max  # assumes at least one numeric in column
      send @__read_minmax_max
    end

    def __read_minmax_min_normally
      @_minmax_min
    end

    def __read_minmax_max_normally
      @_minmax_max
    end
  end
end
# #born: for table inference
