function omf.core.update
  # If on the stable channel, checkout the latest tag.
  if test (omf.core.channel) = stable
    # If we are set to the stable channel, but are tracking master instead, the user probably
    # upgraded from an old version of OMF. Let's be nice and switch to the stable channel nicely
    # for them.
    if git -C "$OMF_PATH" symbolic-ref -q HEAD > /dev/null
      set_color $fish_color_quote ^/dev/null; or set_color yellow --bold
      echo ">> You have been switched to the stable release channel of Oh My Fish."
      echo ">> To switch back to the development channel, run `omf channel dev`."
      set_color normal
    end

    # Determine the remote to fetch from.
    set -l remote origin
    if test (command git -C "$OMF_PATH" config --get remote.upstream.url)
      set remote upstream
    end

    # Fetch the latest tags.
    command git -C "$OMF_PATH" fetch --quiet --tags $remote master
      or return 1

    # Get the latest stable version.
    if set -l hash (command git -C "$OMF_PATH" rev-list --quiet --tags --max-count=1 ^ /dev/null)
      # Check out the tag.
      set -l tag (command git -C "$OMF_PATH" describe --tags $hash)
        and command git -C "$OMF_PATH" checkout --quiet tags/$tag
        or return 1
    end

    # No tags available, so assume success.
    return 0
  else
    # Switch to the master branch if we are in a detached head.
    command git -C "$OMF_PATH" symbolic-ref -q HEAD > /dev/null
      or command git -C "$OMF_PATH" checkout master --quiet

    # Pull the latest for the current branch.
    omf.repo.pull $OMF_PATH
  end
end
