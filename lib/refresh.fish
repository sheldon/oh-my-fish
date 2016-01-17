# SYNOPSIS
#   refresh
#
# OVERVIEW
#   Refresh (reload) the current fish session.

function refresh -d "Refresh fish session by replacing current process"
  if not set -q CI
    history --save
    set -gx dirprev $dirprev
    set -gx dirnext $dirnext
    set -gx dirstack $dirstack
    set -gx fish_greeting ''
    exec fish < /dev/tty
  end
end
