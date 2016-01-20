function omf.repo.pull -a repo_dir

  if test (count $argv) -eq 0
    echo (omf::err)"omf.repo.pull takes a repository path as an argument."(omf::off) 1>&2
    return $OMF_MISSING_ARG
  end

  function __omf.repo.git -V repo_dir
    command git -C "$repo_dir" $argv
  end

  test (__omf.repo.git config --get remote.upstream.url)
    and set remote upstream
    or set remote origin

  set initial_branch (__omf.repo.git symbolic-ref -q --short HEAD)
    or return 1
  set initial_revision (__omf.repo.git rev-parse -q --verify HEAD)
    or return 1

  # compare against remote branch
  __omf.repo.git diff --quiet master $remote/master; and return 2

  # a refspec which ensures that '$remote/master' gets updated
  set -l refspec "refs/heads/master:refs/remotes/$remote/master"

  __omf.repo.git fetch --quiet $remote $refspec; or return 1

  if not __omf.repo.git diff --quiet
    echo (omf::em)"Stashing your changes:"(omf::off)
    __omf.repo.git status --short --untracked-files
    __omf.repo.git stash save --include-untracked --quiet;
      and set stashed
  end

  if test "$initial_branch" != master
    __omf.repo.git checkout master --quiet
  end

  if not __omf.repo.git merge --ff-only --quiet FETCH_HEAD
    __omf.repo.git checkout $initial_branch
    __omf.repo.git reset --hard $initial_revision
    set -q stashed; and __omf.repo.git stash pop
    return 1
  end

  if test "$initial_branch" != master
    __omf.repo.git checkout $initial_branch --quiet
  end

  if set -q stashed
    __omf.repo.git stash pop --quiet

    echo (omf::em)"Restored your changes:"(omf::off)
    __omf.repo.git status --short --untracked-files
  end

  return 0
end
