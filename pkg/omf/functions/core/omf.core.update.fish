function omf.core.update
  set packages_before (omf.packages.list --available)

  omf.repo.pull $OMF_PATH >/dev/null 2>&1
  set pull_status $status

  test "$pull_status" != 0
    and return $pull_status

  set packages_after (omf.packages.list --available)

  for package in $packages_after
    not contains $package $packages_before; and echo $package
  end

  return $pull_status
end
