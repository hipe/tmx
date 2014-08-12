module Skylab::Callback

    class Ordered_Dictionary  # read [#037]

      class << self

        alias_method :orig_new, :new

        def new * i_a
          i_a.freeze
          ::Class.new( self ).class_exec do
            class << self
              alias_method :new, :orig_new
            end
            _BOX_ = Callback_::Lib_::Entity[].box.new
            define_method :ordered_dictionary do
              _BOX_
            end
            i_a.each do |i|
              slot = Callback_Slot__.new i

              _BOX_.add i, slot

              attr_reader slot.attr_reader

              ivar = slot.ivar
              define_method :"receive_#{ i }_event" do |ev|  # [#039]
                p = instance_variable_get ivar
                p && p[ ev ]
              end
            end
            self
          end
        end
      end

      def initialize * p_a
        box = ordered_dictionary
        p_a.each_with_index do |p, d|
          instance_variable_set box.at_position( d ).ivar, p
        end
        ( p_a.length ... box.length ).each do |d|
          instance_variable_set box.at_position( d ).ivar, nil
        end ; nil
      end

      class Callback_Slot__
        def initialize i
          @attr_reader = :"#{ i }_p"
          @ivar = :"@#{ @attr_reader }"
        end
        attr_reader :attr_reader, :ivar
      end
    end
end
