#!/bin/bash

set -e

UTILDIR=$(cd $(dirname $0) && pwd)
BASEDIR=$(cd "$UTILDIR/.." && pwd)
SRCDIR="$BASEDIR/src"
TOOLSDIR="$SRCDIR/js/util/buildscripts"
PROFILE="$SRCDIR/js/app/_base.js"
CSSDIR="$SRCDIR/css"
DISTDIR="$BASEDIR/dist"

if [ ! -d "$TOOLSDIR" ]; then
    echo "Can't find Dojo build tools -- did you initialise submodules? (git submodule update --init --recursive)"
    exit 1
fi

if [ ! -f "$PROFILE" ]; then
    echo "Invalid input profile"
    exit 1
fi

echo "Using $PROFILE. CSS will be copied and JS will be built."

# clean the old distribution files
echo -n "Cleaning old files..."
rm -rf "$DISTDIR"
echo " Done"

cd "$TOOLSDIR"

if which node >/dev/null; then
    node ../../dojo/dojo.js load=build --check --loader "$PROFILE" "$@"
elif which java >/dev/null; then
    java -Xms256m -Xmx256m  -cp ../shrinksafe/js.jar:../closureCompiler/compiler.jar:../shrinksafe/shrinksafe.jar org.mozilla.javascript.tools.shell.Main  ../../dojo/dojo.js baseUrl=../../dojo load=build --check --loader "$PROFILE" "$@"
else
    echo "Need node.js or Java to build!"
    exit 1
fi

cd "$UTILDIR"

# copy the css files
# todo: how to do this better?
cp -r "$CSSDIR" "$DISTDIR/css"

# copy the index.html and make it production-friendly
cp "$SRCDIR/index.html" "$DISTDIR/index.html"

echo "Build complete"
