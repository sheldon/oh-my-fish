function require
  set packages $argv

  if test -z "$packages"
    echo 'usage: require <name>...'
    echo '       require --path <path>...'
    return 1
  end

  # Requiring absolute paths
  if set index (contains -i -- --path $packages)
    set -e packages[$index]
    set package_path $packages

  # Requiring specific packages from default paths
  else
    # Remove packages which have already been loaded.
    for package in $packages
      if contains -- $package $omf_packages_loaded
        set index (contains -i -- $package $packages)
        set -e packages[$index]
      end
    end

    # Exit without error if packages already loaded
    test -z "$packages"
      and return 0

    set package_path {$OMF_PATH,$OMF_CONFIG}/pkg*/$packages

    # Exit with error if no package paths were generated
    test -z "$package_path"
      and return 1
  end

  set function_path $package_path/functions*
  set completion_path $package_path/completions*
  set init_path $package_path/init.fish*

  # Autoload functions
  test -n "$function_path"
    and set fish_function_path $fish_function_path[1] \
                               $function_path \
                               $fish_function_path[2..-1]

  # Autoload completions
  test -n "$complete_path"
    and set fish_complete_path $fish_complete_path[1] \
                               $complete_path \
                               $fish_complete_path[2..-1]

  for init in $init_path
    set -l IFS '/'
    echo $init | read -la components

    set path (printf '/%s' $components[1..-2])

    # If we are requiring a package
    if contains -- pkg $components
      set package $components[-2]

      contains $package $omf_packages_loaded
        and continue

      set bundle $path/bundle
      set dependencies

      if test -f $bundle
        set -l IFS ' '
        while read -l type dependency
          test "$type" != package
            and continue
          require "$dependency"
          set dependencies $dependencies $dependency
        end < $bundle
      end
    end

    source $init $path
    emit init_$package $path

    set -g omf_packages_loaded $omf_packages_loaded $package
  end

  return 0
end
