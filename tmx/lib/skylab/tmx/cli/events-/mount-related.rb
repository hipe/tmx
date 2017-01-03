module Skylab::TMX

  class CLI

    class When_

      class << self
        def call * x_a
          new( * x_a ).execute
        end
        alias_method :[], :call
        private :new
      end  # >>

      class No_arguments < self

        def initialize omni, cli
          _receive_omni omni
          super cli
        end

        def execute

          o = @omni
          @listener.call :error, :expression, :parse_error do |y|
            if o.has_operators
              if o.has_primaries
                buff = "available operators and primaries: "
                scn = o.to_operation_symbol_scanner.concat o.to_primary_symbol_scanner
              else
                buff = "available operators: "
                scn = o.to_operation_symbol_scanner
              end
            else
              buff = "available primaries: "
              scn = o.to_primary_symbol_scanner
            end
            scn = scn.map_by do |sym|
              prim sym
            end
            scn.oxford_join buff, ' and ', ', '
            y << buff
          end
          UNABLE_
        end
      end

      # -

        def initialize cli
          @CLI = cli
        end

        def _receive_omni omni
          @listener = omni.argument_scanner.listener
          @omni = omni ; nil
        end
      # -
    end

  if false
  class Models_::Reactive_Model_Dispatcher

    Events_ = ::Module.new

    cls = Common_::Event.prototype_with(

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

    cls = Common_::Event.prototype_with(

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
  end  # if false

    Events_::Mount_Related = ::Module.new  # until the pending rename #here
  end
end
# #pending-rename: when-  (and see #here)
