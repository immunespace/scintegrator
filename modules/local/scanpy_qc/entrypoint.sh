#!/bin/bash
# Create the cache directory and set permissions
mkdir -p /.cache
chmod 777 /.cache  # Make it writable by anyone, adjust permissions as appropriate

# Continue with the main command
exec "$@"
