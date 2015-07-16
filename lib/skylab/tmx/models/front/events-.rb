module Skylab::TMX

  class Models::Front

    Events_ = ::Module.new

    cls = Callback_::Event.prototype_with(

      :missing_first_argument,
      :unbound_stream_builder, nil,
      :error_category, :argument_error,
      :ok, false,

    ) do | y, o |

      st = o.unbound_stream_builder[]
      o = st.gets
      if o
        y << "missing first argument."
      else
        y << "there are no reactive nodes."
      end
    end

    def cls.[] guy
      super(
        guy.unbound_stream_builder,
      )
    end

    Events_::Missing_First_Argument = cls

    cls = Callback_::Event.prototype_with(

      :no_such_reactive_node,
      :argument_x, nil,
      :unbound_stream_builder, nil,
      :error_category, :argument_error,
      :ok, false,

    ) do | y, o |

      y << "unrecognized argument #{ ick o.argument_x }"

      st = o.unbound_stream_builder[]
      o = st.gets
      if o

        p = -> unbound do
          unbound.description_under self
        end

        s_a = [ p[ o ] ]
        o_ = st.gets
        if o_
          o__ = st.gets
          if o__
            s_a.push ', ', p[ o_ ], ', etc.'
          else
            s_a.push ' or ', p[ o_ ]
          end
        end
        y << "expecting #{ s_a.join }"
      else
        y << "there are no reactive nodes."
      end
    end

    def cls.[] guy
      super(
        guy.first_argument,
        guy.unbound_stream_builder,
      )
    end

    Events_::No_Such_Reactive_Node = cls
  end
end
