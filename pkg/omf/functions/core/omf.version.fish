function omf.version
  command git -C "$OMF_PATH" describe --tags --match 'v*' --dirty --always | sed 's/^v\([[:digit:]]\+\)/\1/'
end
