# SYNOPSIS
#   require [name]
#
# OVERVIEW
#   Require a plugin:
#     - Autoload its functions and completions.
#     - Require bundle dependencies.
#     - Source its initialization file.
#     - Emit its initialization event.
#
#   If the required plugin has already been loaded, does nothing.

function require
  for name in $argv
    contains -- $name $OMF_IGNORE
      and continue

    contains -- $name $OMF_LOADED
      and continue

    for path in {$OMF_PATH,$OMF_CONFIG}/pkg/$name
      not test -d $path
        and continue

      test -d $path/functions
        and autoload $path/completions $path/functions
        or  autoload $path/completions $path

      if test -f $path/bundle
        read -z -l bundle < $path/bundle
        for line in (echo $bundle)
          set line (echo $line)
          test $line[1] = package
            and set dependency (basename $line[2])
            and require $dependency
        end
      end

      source $path/init.fish ^/dev/null
        or source $path/$name.fish ^/dev/null
        and emit init_$name $path

      set -g OMF_LOADED $OMF_LOADED $name
    end
  end

  functions -e init  # Cleanup previously sourced function

  return 0
end
