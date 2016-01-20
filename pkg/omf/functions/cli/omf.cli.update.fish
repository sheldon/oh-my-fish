function omf.cli.update
  set up_to_date
  set packages_added (omf.core.update)

  switch $status
  case 0
    printf "%sOh My Fish sucessfully updated%s\n" \
           (set_color $fish_color_match) \
           (set_color normal)

    if test -n "$packages_added"
      printf "\n%sPackages Added:%s\n\n" (set_color -u) (set_color normal)
      echo $packages_added | column
      set -e up_to_date
    end

  case 1
    printf "%sOh My Fish failed to update%s\n" \
           (set_color $fish_color_error) \
           (set_color normal)
    printf "Head to %sgithub.com/oh-my-fish/oh-my-fish/issues%s and report your issue\n" \
           (set_color $fish_color_valid_path) \
           (set_color normal)
  end

  for package in (omf.packages.list --installed)
    omf.packages.update $package
      and set -e up_to_date
  end

  set -q up_to_date
    and echo "Already up to date!"

  return 0
end
