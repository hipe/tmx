module Skylab::Face

  module API::Normalizer_  # #method-cherry-bushel [#mh-051]

    def self.enhance_client_class client, *which_a
      which_a.length.zero? and which_a << :conventional
      (( a = SET_H_[ which_a.fetch 0 ] )) and which_a[ 0..1 ] = a  # wow neato
      me = self
      client.module_exec do
        while (( m = which_a.shift ))
          pub_priv, c = H_.fetch m
          define_method m, & me.const_get( c )
          :private == pub_priv and private m
        end
      end
      nil
    end
    H_ = {
      normalize: [ :public, :Normalize_method_ ],
      field_normalize: [ :public, :Field_normalize_method_ ],
      field_value_notify: [ :public, :Field_value_notify_method_ ],
      flush: [ :public, :Flush_method_ ]
    }.tap{ |h| h.values.each( & :freeze ) }.freeze
    SET_H_ = -> do
      o = { }
      o[ :all ] = (( o[ :conventional ] =
        %i( normalize field_normalize field_value_notify ) )).dup << :flush
      o.freeze
    end.call
    #
    Normalize_method_ = -> y, par_h do  # assume `any_expression_agent`
      _fb = field_box
      _noti = Normalization_.new :any_expression_agent, any_expression_agent,
        :field_box, _fb, :notice_yielder, y, :notifiee, self,
        :param_h, par_h
      _noti.execute
    end
    #
    Field_normalize_method_ = -> y, fld, x do  # assume `field_value_notify`
      # assume `y` and `x` as [#019]. assume `fld` has one or more of default
      # proc, normalizer. RESULT IS TUPLE OF: (is_invalid, is_absent, use_x)

      is_absent = x.nil?
      if fld.has_default && is_absent
        x = instance_exec( & fld.default_value )
        field_value_notify fld, x
        is_absent = x.nil?
      end
      if fld.has_normalizer
        befor = y.count
        true == (( normalizer_p = fld.normalizer_value )) and
          normalizer_p = method( :"normalize_#{ fld.local_normal_name }" )
        is_absent = ! ( instance_exec y, x, -> valid_x do
          field_value_notify fld, valid_x
          x = valid_x
          nil
        end, & normalizer_p )  # tome at [#019]
        is_invalid = befor != y.count
      end
      [ is_invalid, is_absent, x ]
    end
    #
    Field_value_notify_method_ = -> fld, x do
      instance_variable_set fld.as_host_ivar, x
      nil
    end

    Build_say_method_ = -> topic_expression_agent_p do
      -> &blk do
        topic_expression_agent = instance_exec( & topic_expression_agent_p )
        r = topic_expression_agent.instance_exec( & blk )
        r and fail "sanity - no support for `say` that has result yet"
        nil
      end
    end

    module Sayer_

    private

      def say &blk
        @y << some_expression_agent.instance_exec( & blk )
        nil
      end

      def some_expression_agent
        @any_expression_agent || Expr_ag__[]
      end
    end

    class Normalization_ ; include Sayer_

      # mutates param_h [#019] [#bl-013] [#sl-116]

      Lib_::Fields_via[ :client, self, :method, :initialize, :field_i_a,
        %i( any_expression_agent field_box notice_yielder notifiee param_h ) ]

      def execute
        resolve_notifiers
        @y = @notice_yielder ; par_h = @param_h ; miss_a = nil
        av = Arity_Validator_.new @y, @any_expression_agent
        r = false ; befor = @y.count
        @field_box.each_pair do |i, fld|
          x = ( par_h.delete i if par_h and par_h.key? i )
          @field_value_notify_p[ fld, x ]
          if fld.has_normalizer || fld.has_default  # yes after
            is_invalid, is_absent, x = @field_normalize_p[ @y, fld, x ]
            is_invalid and next
          else
            is_absent = x.nil?
          end
          if fld.is_required && is_absent
            next( ( miss_a ||= [] ) << fld )
          end
          av.validate_field_against_value fld, x
        end
        begin
          Some_[ par_h ] and break say_undeclared( par_h )
          miss_a and break say_missing miss_a
          @y.count > befor and break
          r = true
        end while nil
        r
      end

    private

      def resolve_notifiers
        @field_value_notify_p = Method_or_proc_[
          @notifiee, :field_value_notify, Field_value_notify_ ]
        @field_normalize_p = Method_or_proc_[
          @notifiee, :field_normalize, Field_normalize_ ]
        nil
      end
      #
      Method_or_proc_ = -> obj, meth_i, proc_p do
        obj.respond_to?( meth_i ) ? obj.method( meth_i ) : proc_p.curry[ obj ]
      end
      #
      Functionalize_meth_proc_ = -> p do
        case p.arity
        when 2 ; -> o, a, b    { o.instance_exec a, b, &p }
        when 3 ; -> o, a, b, c { o.instance_exec a, b, c, &p }
        else   ; fail "unhack or pro-hack me"
        end      # sadly this is the cleanest way to preserve absolute arity
      end        # which is necessary for curry to work without coupling
      #
      Field_value_notify_ = Functionalize_meth_proc_[Field_value_notify_method_]
      #
      Field_normalize_ = Functionalize_meth_proc_[ Field_normalize_method_ ]

      def say_undeclared par_h
        a = par_h.keys ; mon = moniker
        say do
          "undeclared parameter#{ s a } #{ and_ a.map( & method( :ick ) ) } #{
            }for #{ mon }. (declare #{ s :them } with `params` macro?)"
        end
        nil
      end

      def say_missing a
        mon = moniker
        say do
          "missing required parameter#{ s a } #{
            }#{ and_ a.map( & method( :par ) ) } for #{ mon }"
        end
        nil
      end

      def moniker
        @notifiee.class
      end
    end

    class Arity_Validator_ ; include Sayer_

      def initialize notice_yielder, any_expression_agent
        @y = notice_yielder ; @any_expression_agent = any_expression_agent
      end

      def validate_field_against_value fld, x
        @fld = fld ; @x = x
        if fld.some_arity.is_polyadic  # be careful foo
          validate_many_against_value
        elsif fld.some_argument_arity.is_zero
          ( ! x ) or true == x or detailed_monadic_niladic_errmsg
        elsif x.respond_to? :each_with_index
          say_multiple
        end
        nil  # keep life simple and let the erronity be reflected in y.count
      end

    private

      def say_multiple
        fld_object = @fld
        say do
          "multiple arguments were provided for #{ par fld_object } but #{
            }only one can be accepted"  # note at [#050]
        end
      end

      def validate_many_against_value
        bfr = @y.count
        if @fld.some_argument_arity.is_zero
          @x.nil? or @x.respond_to? :even? or say_not_integer
        else
          @x.nil? or @x.respond_to? :each_with_index or say_not_array
        end
        if (bfr == @y.count && ! @fld.some_arity.includes_zero && ! Some_[@x])
          say_must_have
        end
        nil
      end

      def say_not_integer
        fld = @fld ; x = @x
        say do
          "strange shape for #{ par fld } - when arity is many and #{
            }argument arity is zero, the value should be an integer, #{
            }had #{ ick x }"
        end
      end

      def say_not_array
        fld = @fld ; x = @x
        say do
          "strange shape for #{ par fld } - when arity is many and argument #{
            }arity is one, expected array-like, had #{ ick x }"
        end
      end

      def say_must_have
        fld = @fld
        say do
          "must have #{ hack_label fld.some_arity.local_normal_name }#{
            } #{ par fld }"
        end
      end

      def detailed_monadic_niladic_errmsg
        if @x.respond_to? :even?
          say_too_many
        else
          say_not_true
        end
        nil
      end

      def say_too_many
        fld = @fld ; x = @x
        say do
          "#{ par fld } was specified #{ x } times but is not #{
            }meaningful to be specified more than once"  # take a chance
        end
      end

      def say_not_true
        fld = @fld ; x = @x
        say do
          "strange shape for #{ par fld } - when arity is max one #{
            }and argument arity is zero, the only valid value value is #{
            }`true`, had #{ ick x }"

        end
      end
    end

    #                  ~ various ways to employ validation ~

    Flush_method_ = -> do  # #experimental new interface for API actions
      # assume `field_box` @infostream `any_expression_agent` @param_h
      # normalize and then (maybe) execute. like an `invoke` but takes no
      # arguments, to facilitate progressive request building and then one
      # final flushing.

      @y ||= ::Enumerator::Yielder.new( & @infostream.method( :puts ) )
      cy = Lib_::Counting_yielder[ @y.method :<< ]
      _fb = field_box ; _exag = any_expression_agent
      _norm = Normalization_.new :field_box, _fb, :notifiee, self,
        :any_expression_agent, _exag, :notice_yielder, cy,
        :param_h, @param_h
      ok = _norm.execute
      ok &&= execute
      ok
    end

    Hack_label = -> name_i do
      Chomp_sing_ltr_sfx_[ name_i ].gsub '_', ' '
    end
    #
    Chomp_sing_ltr_sfx_ = API::Procs::Chomp_single_letter_suffix

    Expression_agent_class = -> do
      # (while we figure out who we are we procede very cautiously and
      # a) lazy load to avoid problems and b) cherry-pick only what we need)
      # [#084]

      p = -> do

        class Expression_Agent__

          Lib_::EN_add_private_methods_to_module[ %i( s and_ or_ both ), self ]


        private

          def par fld_x
            if fld_x.respond_to? :id2name
              i = fld_x
            else
              i = fld_x.local_normal_name
            end
            "\"#{ hack_label i }\""
          end

          define_method :hack_label, & Hack_label

          def ick x  # :+[#mh-050] family
            if x.respond_to? :id2name
              "'#{ x }'"
            else
              Inspct__[ x ]
            end
          end
          #
          Inspct__ = Lib_::Inspect_proc[].
            curry[ A_REASONABLY_SHORT_LENGTH_FOR_A_STRING__ = 10 ]
        end
        p = -> { Expression_Agent__ }
        Expression_Agent__
      end
      -> { p[] }
    end.call

    Expr_ag__ = -> do
      p = -> do
        expag = Expression_agent_class[].new
        p = -> { expag }
        expag
      end
      -> { p[] }
    end.call

    class Field_Front_Exp_Ag_  # a HUGE experiment VERY primordial! (and messy)
      def initialize field_box, down_expression_agent
        @field_box = field_box
        @down_expression_agent = down_expression_agent
      end

      alias_method :calculate, :instance_exec

    private

      def par fld
        if fld.respond_to? :id2name
          (( field = @field_box.fetch fld do end )) and fld = field
        end
        @down_expression_agent.par fld
      end

      %i| hack_label ick kbd s or_ and_ both |.each do |m|  # etc mm proxy
        define_method m do |*a|
          @down_expression_agent.send m, *a
        end
      end
    end
  end
end
