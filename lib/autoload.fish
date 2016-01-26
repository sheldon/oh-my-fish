# SYNOPSIS
#   autoload <path>...
#   autoload -e <path>...
#
# OVERVIEW
#   Manipulate autoloading path components.
#
#   If called without options, the paths passed as arguments are added to
#   $fish_function_path. All paths ending with `completions` are correctly
#   added to $fish_complete_path. Returns 0 if one or more paths exist. If all
#   paths are missing, returns != 0.
#
#   When called with -e, the paths passed as arguments are removed from
#   $fish_function_path. All arguments ending with `completions` are correctly
#   removed from $fish_complete_path. Returns 0 if one or more paths erased. If
#   no paths were erased, returns != 0.

function autoload -d "Manipulate autoloading path components"
  set -l paths $argv

  switch "$argv[1]"
  case '-e' '--erase'
    set erase

    if test (count $argv) -ge 2
      set paths $argv[2..-1]
    else
      echo "usage: autoload $argv[1] <path>..." 1>&2
      return 1
    end
  case "-*" "--*"
    echo "autoload: invalid option $argv[1]"
    return 1
  end

  for path in $paths
    not test -d "$path"
      and continue

    if test (basename "$path") = completions
      set dest completions
      set fish_path fish_complete_path
    else
      set dest functions
      set fish_path fish_function_path
    end

    if set -l index (contains -i -- "$path" $$fish_path)
      set -q erase; and set $dest $index $$dest
    else
      set -q erase; or  set $dest $path $$dest
    end
  end

  if set -q erase
    test -n "$completions"
      and set -e fish_complete_path[$completions]
    test -n "$functions"
      and set -e fish_function_path[$functions]
    set return_success
  else
    test -n "$completions"
      and set fish_complete_path $completions $fish_complete_path
    test -n "$functions"
      and set fish_function_path $functions $fish_function_path
    set return_success
  end

  set -q return_success
end
