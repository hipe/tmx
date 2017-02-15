module Skylab::Common

  class Event

    module Makers_::Data_Event  # :[#005.E].

      class << self
        def new * i_a
          ::Module.new.module_exec do
            extend Module_Methods__
            i_a.freeze
            define_singleton_method :members do
              i_a
            end
            self
          end
        end
      end  # >>

      module Module_Methods__

        def [] * a
          new_via_arglist a
        end

        def new_via_arglist a
          evnt_class.call_via_arglist a
        end

      private

        def evnt_class
          @evnt_cls ||= bld_event_class
        end

        def bld_event_class
          x_a = [ name_symbol ]
          members.each do |i|
            x_a.push i, nil
          end
          x_a.push :ok, true
          ecls = Event_.prototype.via_deflist_and_message_proc x_a, nil
          const_set :Event___, ecls
          ecls
        end

        def name_symbol
          Home_::Name.via_module( self ).as_variegated_symbol
        end
      end
    end

    module Makers_::Message  # :[#005.E] (see)

      class << self

        def new * x_a, & p
          ::Class.new( Message__ ).class_exec do
            const_set :P___, p
            const_set :X_A__, ( x_a.freeze if x_a.length.nonzero? )
            self
          end
        end
      end

      class Message__

        class << self

          def [] * a
            new do
              @a = a
            end
          end

          def new_via_arglist a
            new do
              @a = a
            end
          end

          def event_cls
            @ec ||= bld_event_class
          end

        private

          def bld_event_class
            x_a = [ name_symbol ]
            msg_p = self::P___
            _NAME_I_A = []
            msg_p.parameters.each do |(_, i)|
              _NAME_I_A.push i
              x_a.push i, nil
            end
            x_a.push :original_message_proc, msg_p

            x_a_ = self::X_A__
            if x_a_
              x_a.concat x_a_
            else
              x_a.push :ok, false  # meh
            end

            cls = Event_.prototype.via_deflist_and_message_proc x_a, ( -> y, o do
              _a = _NAME_I_A.map do |i|
                o.send i
              end
              y << instance_exec( * _a, & o.class::P____ )
            end )
            cls.const_set :P____, msg_p
            const_set :Event___, cls
            cls
          end

          def name_symbol
            Home_::Name.via_module( self ).as_variegated_symbol
          end
        end  # >>

        def initialize & p
          instance_exec( & p )
          freeze
        end

        def to_event
          self.class.event_cls.call_via_arglist @a
        end
      end
    end
  end
end
# NOTE: the below posterity entry refers to [#br-001], which is now [#fi-034]
# :+#posterity message event may have been earliest version of [#br-001]
