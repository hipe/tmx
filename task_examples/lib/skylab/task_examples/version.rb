module Skylab::TaskExamples

  class Version

    class << self

      def parse str, & oes_p
        Parse___[ str,  self, & oes_p ]
      end

      alias_method :__new, :new
      undef_method :new
    end  # >>

    REGEX = / (?<major>\d+) \. (?<minor>\d+) (?:\. (?<patch>\d+) )? /x

    NOT_VERSION__ = /(?:(?!#{ REGEX.source }).)+/x

    class Parse___ < Common_::Dyadic

      def initialize str, base_cls, & oes_p
        @string = str
        @base_class = base_cls
        @_oes_p = oes_p
      end

      def execute

        @_scan = Home_::Library_::StringScanner.new remove_instance_variable :@string

        ok = __match_one_match
        ok &&= __do_not_match_another_match
        ok && ___finish
      end

      def ___finish

        lc = remove_instance_variable :@_leading_chaff
        tc = remove_instance_variable :@_trailing_chaff
        _md = remove_instance_variable :@_matchdata

        _Sexp = Home_.lib_.basic::Sexp

        o = -> * a do
          _Sexp.new a
        end

        sexp = o[ :version_string ]
        if lc
          sexp.push o[ :string, lc ]
        end

        sexp.push o[ :version_object, @base_class.__new( _md ) ]

        if tc
          sexp.push o[ :string, tc ]
        end

        sexp
      end

      def __match_one_match

        chaff = @_scan.scan NOT_VERSION__
        match = @_scan.scan REGEX
        if match
          @_leading_chaff = chaff
          @_matchdata = REGEX.match match  # because strscan don't play that
          ACHIEVED_
        else
          ___when_etc
        end
      end

      def ___when_etc
        s = @_scan.string
        _oes_p.call :error, :expression do |y|
          y << "version pattern not matched anywhere in string: #{ ick s }"
        end
        UNABLE_
      end

      def __do_not_match_another_match

        trailing_chaff = @_scan.scan NOT_VERSION__
        again = @_scan.scan REGEX
        if again
          ___when_oh_noes
        else
          @_scan.eos? or self._REGEX_SANITY
          @_trailing_chaff = trailing_chaff
          ACHIEVED_
        end
      end

      def ___when_oh_noes
        s = @_scan.string
        _oes_p.call :error, :expression, :ambiguous do |y|
          y << "multiple version strings matched in string: #{ ick s }"
        end
        UNABLE_
      end

      def _oes_p
        if @_oes_p
          @_oes_p
        else
          Default_on_event_selectively___
        end
      end
    end

    # -

      def initialize md  # ..

        s = md[ :major ]
        s_ = md[ :minor ]

        s__ = md[ :patch ]

        if s__
          patch = s__.to_i
        end

        @major = s.to_i
        @minor = s_.to_i

        @patch = patch
      end

      def bump! sym
        ivar = :"@#{ sym }"
        d = remove_instance_variable( ivar ) || 0  # sanity checks name  BE CAREFUL
        d += 1
        instance_variable_set ivar, d
        d
      end

      def unparse_to io
        s = "#{ @major }.#{ @minor }"
        d = @patch
        if d
          s.concat ".#{ d }"
        end
        io << s
      end

      def has_minor_version?
        @minor
      end

      def has_patch_version
        @patch
      end

    # -

    Default_on_event_selectively___ = -> * i_a, & ev_p do  # #[#ca-066]

      if :info == i_a.first
        UNRELIABLE_
      elsif :expression == i_a[ 1 ]

        _expag = Home_.lib_.brazen::API.expression_agent_instance
        _msg = _expag.calculate "", & ev_p
        raise ::ArgumentError, _msg

      else
        self._UNIFY_ME
      end
    end

    Here_ = self
  end
end
