#!/bin/bash
set -e

# Figure out where this script is located.
SELFDIR="`dirname \"$0\"`"
SELFDIR="`cd \"$SELFDIR\" && pwd`"

# Run the actual app using the bundled Ruby interpreter.
exec "$SELFDIR/lib/ruby/bin/ruby" "$SELFDIR/lib/app/hello.rb"
