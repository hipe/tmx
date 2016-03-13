module Skylab::Fields

  class Attributes

    class Normalization  # see [#012]

      Normalize_using_defaults_and_requireds = -> sess, & oes_p do

        attrs = sess.class::ATTRIBUTES
        if attrs
          o = self.begin( & oes_p )
          idx = attrs._index
          sidx = idx._static_index
          o.effectively_defaultants = sidx.effectively_defaultants
          o.lookup = idx.lookup_attribute_proc_
          o.requireds = sidx.requireds
          o.store = sess
          _ = o.execute
          _
        else
          ACHIEVED_
        end
      end

      class << self

        alias_method :begin, :new
        undef_method :new
      end  # >>

      def initialize & oes_p
        @_oes_p = oes_p  # can be nil
      end

      attr_writer(
        :effectively_defaultants,
        :lookup,
        :requireds,
        :store,
      )

      def execute

        _ok = __maybe_check_for_missing_requireds
        _ok && ___maybe_apply_defaulting
      end

      def ___maybe_apply_defaulting
        # (per #spot-2 this will always occur but in case that changes..)
        if @effectively_defaultants
          ___do_apply_defaulting
        else
          ACHIEVED_
        end
      end

      def ___do_apply_defaulting

        @effectively_defaultants.each do |k|
          attr = @lookup[ k ]
          # experimental (ick) "optimization ..
          ivar = attr.as_ivar
          if @store.instance_variable_defined? ivar
            was_defined = true
            x = @store.instance_variable_get ivar
          end

          if x.nil?
            p = attr.default_proc
            if p
              @store.instance_variable_set ivar, p[]
            elsif ! was_defined
              @store.instance_variable_set ivar, nil
            end
          end
        end

        ACHIEVED_
      end

      def __maybe_check_for_missing_requireds
        if @requireds
          ___check_for_missing_requireds
        else
          ACHIEVED_
        end
      end

      def ___check_for_missing_requireds

        miss_a = nil

        @requireds.each do |k|

          attr = @lookup[ k ]
          ivar = attr.as_ivar

          if @store.instance_variable_defined? ivar
            x = @store.instance_variable_get ivar
          end

          if x.nil?
            ( miss_a ||= [] ).push attr
          end
        end

        if miss_a
          ___when_missing_requireds miss_a
        else
          ACHIEVED_
        end
      end

      def ___when_missing_requireds miss_a

        build_event = -> do
          Home_::Events::Missing.via miss_a, 'attribute'
        end

        if @_oes_p
          @_oes_p.call :error, :missing_required_attributes do
            build_event[]
          end
          UNABLE_
        else
          _ev = build_event[]
          raise _ev.to_exception
        end
      end

      Get_parameter_controller_moniker = -> ent do  # legacy

        s_a = ent.class.name.split CONST_SEP_

        case 2 <=> s_a.length
        when -1  # long
          s_a = s_a[ -2 .. -1 ]
          has_two = true
        when 0
          has_two = true
        end

        if has_two
          if UNDERSCORE_ == s_a.first[ -1 ]  # assume Actors_::Foo
            s_a.shift
          else
            s_a.reverse!  # assume Noun::Verb -> 'verb noun'
          end
        end

        p = Callback_::Name::Conversion_Functions::Pathify
        s_a.map do | s |
          p[ s ]
        end * SPACE_
      end

      CONST_SEP_ = '::'
      UNDERSCORE_ = '_'
    end
  end
end
