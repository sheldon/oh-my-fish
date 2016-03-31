function omf.core.channel -a name
  # If an argument is specified, set the update channel.
  if test -n "$name"
    if not contains -- $name stable dev
      echo (omf::err)"'$name' is not a valid channel."(omf::off) 1^&2
      return 1
    end

    echo $name > $OMF_CONFIG/channel
    echo "Update channel set to '$name'."
    return 0
  end

  # If no argument is provided, print out the current update channel.
  # Check for an environment variable override.
  if set -q OMF_CHANNEL
    echo $OMF_CHANNEL
    return 0
  end

  # Check the channel file.
  if test -f $OMF_CONFIG/channel
    read -l channel < $OMF_CONFIG/channel
      and echo $channel
      and return 0
  end

  # Assume 'stable' if not specified.
  echo stable
end
