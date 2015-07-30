module Skylab::Headless

  module Bundles__::Delegating  # read [#060] #storypoint-505 introduction

    Absorb_Passivley = -> x_a, mod do
      pi = PI__.new x_a, mod
      begin
        if pi
          _did = pi.absorb_any_sub_phrases
          _did and next
        end
        dpi = Delegating::Delegating_Phrase_Interpreter.new x_a
        _did = dpi.interpret_any_delegating_phrase
        _did or break
        pi &&= nil
        bldr = dpi.resolve_some_builder
        dpi.resolve_some_method_name_a.each do |i|
          mod.send :define_method, i, bldr.build_method( i )
        end
      end while x_a.length.nonzero?
    end

    class PI__ < Delegating::Phrase_Interpreter
      def initialize x_a, mod
        @mod = mod
        super x_a
      end
    private
      def employ_the_DSL_method_called_delegates_to=
        @mod.singleton_class.module_exec( & Define_delegates_to_method__ ) ; nil
      end
    end

    Define_delegates_to_method__ = -> do
    private
      def delegates_to delegatee_i, * method_i_a
        method_i_a.each do |m_i|
          define_method m_i do | * a, & p |
            send( delegatee_i ).send m_i, * a, & p
          end
        end
      end
    end

    class Builder_with_if
      def self.[] if_p, builder
        new( if_p, builder )
      end
      def initialize if_p, blder
        @if_p = if_p ; @bldr = blder
      end
      def build_method i
        norm_p = @bldr.build_normalized_proc i
        if_p = @if_p
        -> *a, &p do
          _yes = instance_exec( & if_p )
          if _yes
            instance_exec a, p, & norm_p
          end
        end
      end
    end
  end
end
