module Skylab::Human

  module ExpressionPipeline_::BestMatchingExpression_via_Magnetics

    # exactly [#034] "expression frames" (name will probably change).
    # (looks like [#039] but while similar, is different.)
    # :#spot1.6

    CONST_FRAGMENT__ = '_via_Idea_with_'

    GLOB_ENTRY___ = "*#{ CONST_FRAGMENT__.downcase.gsub UNDERSCORE_, DASH_ }*"

    class << self

      def index_via_magnetics_module__ mod
        Index___.new mod
      end
    end  # >>

    # ==

    BestMatchingExpression_via_LoadableReferenceStream___ = -> idea, st do

        best_match = nil

        begin
          lr = st.gets
          lr || break
          match = lr.dereference.match_for_idea__ idea
          if match
            if best_match
              if best_match <= match
                best_match = match
              end
            else
              best_match = match
            end
          end
          redo
        end while above

        if best_match
          best_match.to_expression_session__
        else
          self._LOGIC_HOLE
        end
    end

    # ==

    class Index___

      # only those magnetics that end in a particular thing in their filename

      # we assume that the subject instance will be cached by the
      # client so we do no additional caching of anything here :#here1

      def initialize mod

        @__index = Home_.lib_.system_lib::Filesystem::Directory::OperatorBranch_via_Directory.define do |o|

          o.startingpoint_path = mod.dir_path

          o.loadable_reference_via_path_by = -> path do

            LoadableReference___.new path, mod
          end

          o.glob_entry = GLOB_ENTRY___
        end
      end

      def interpret_ scn

        _idea = ExpressionPipeline_::Idea_.interpret_ scn
        _st = @__index.to_loadable_reference_stream
        exp = BestMatchingExpression_via_LoadableReferenceStream___[ _idea, _st ]
        exp || self._COVER_ME__not_sure_if_possible__
        exp
      end
    end

    # ==

    class LoadableReference___

      # (ideally this would all push up to [sy] to be next to that o.b)

      def initialize path, mod

        const = Const_via_path___[ path ]

        @dereference = mod.const_get const, false  # trigger autoloading

        @normal_symbol = const  # prob never used
      end

      attr_reader(
        :dereference,
        :normal_symbol,
      )
    end

    # ==

    Const_via_path___ = -> path do

      basename = ::File.basename path
      d = ::File.extname( basename ).length
      _slug = d.zero? ? basename : basename[ 0 ... -d ]
      _terms = _slug.split DASH_
      ExpressionPipeline_::ConstString_via_TermScanner[ Scanner_[ _terms ] ].intern
    end

    # ==
    # ==
  end
end
# #history: that whole name thing moved to its own file
