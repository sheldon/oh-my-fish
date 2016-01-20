function omf.packages.update -a name
  if set target_path (omf.packages.path $name)
    # Skip packages outside version control
    not test -e $target_path/.git; and return 0

    omf.repo.pull $target_path

    switch $status
    case 0
      omf.bundle.install $target_path/bundle
      echo (omf::em)"$name successfully updated."(omf::off)
    case 1
      echo (omf::err)"Could not update $name."(omf::off) 1>&2
    end

    return $status
  else
    echo (omf::err)"Could not find $name."(omf::off) 1>&2
  end

  return 1
end
