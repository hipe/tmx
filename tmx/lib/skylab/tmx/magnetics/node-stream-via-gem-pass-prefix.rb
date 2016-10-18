module Skylab::TMX

  class Magnetics::NodeStream_via_GemPassPrefix

    self._NOT_USED  # #todo

    attr_writer(
      :const_path_prefix,
      :gem_pass_prefix,
    )

    def execute

      # hack-nasty: infer which gems (in *one* directory) are ours using our
      # universal prefix (thank you filesystem) then do some string math to
      # infer what the const name and require path are for each such gem.

      gem_pass_prefix = @gem_pass_prefix

      p = -> path do

        cpp = @const_path_prefix
        filesep = ::File::SEPARATOR
        range_for_basename = path.length - ::File.basename( path ).length .. -1
        range_for_stem = gem_pass_prefix.length .. -1

        p = -> path_ do

          _basename = path_[ range_for_basename ]

          md = RX___.match( _basename )
          if md
            gemname = md[ 0 ]
          else
            self._COVER_ME
            exit 0
          end

          a = cpp.dup
          stem = gemname[ range_for_stem ]
          stem.split( DASH_ ).each do | segment |

            a.push segment.gsub( RX2___ ){ $1.upcase }.intern
          end

          Sidesystem_Name_Inference___.new(
            a, stem, gemname.gsub( DASH_, filesep ), path_ )
        end

        p[ path ]
      end

      _wow = ::Dir[ "#{ ::Gem.paths.home }/gems/#{ gem_pass_prefix }*" ]  # or .path (array))

      Stream_.call _wow do |path|
        p[ path ]
      end
    end

    DASH_ = '-'

    # EGADS: (would be good to use whatever Gem does instead)

    word = '[a-z][a-z_0-9]*'
    verword1 = '[0-9][a-z_0-9]*'
    verword2 = '[a-z0-9][a-z_0-9]*'

    RX___ = /\A
      #{ word } (?: - #{ word } )*
      (?= - #{ verword1 } (?: \. #{ verword2 } )* \z )  # the version part
    /x

    RX2___ = /(?:(?<=^|\d)|_)([a-z])/

    Sidesystem_Name_Inference___ = ::Struct.new(
      :const_path_array, :stem, :require_path, :path_to_gem )

  end
end
