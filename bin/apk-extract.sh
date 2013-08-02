#!/bin/sh

function die {
  echo "$1"
  
  exit 1
}

function find_util {
  local __RESULT_VAR="$1"
  local RESULT="`command -v \"$2\" 2>&1`"
  local URL="$3"
  
  if [ -z "$RESULT" ] ; then
    RESULT="`find . -maxdepth 5 -name \"$2\" 2>&1 | sed 1q 2>&1`"
  fi
  
  if [ -n "$RESULT" ] ; then
    echo "Using $RESULT"
    
    eval $__RESULT_VAR="'$RESULT'"
  
    return 0
  else
    die "! Could not find \"$2\" utility.

Please install \"$2\" (in your PATH or in any subdirectory here).
You can download the utility from $URL"
  fi
}

echo "Extract sources and resources from Android APK"

APK=$1
DST=$2

if [ ! -f "$APK" ] ; then
  die "usage: ${0##*/} file.apk [destination]"
fi

APK_BASENAME=${APK##*/}
APK_BASENAME=${APK_BASENAME%.*}

if [ -z "$DST" ] ; then
  DST=${APK_BASENAME}
fi

if [ -f "$DST" -o -d "$DST" ] ; then
  die "destination already exists"
fi

echo && echo "== Locating utilities ========================================================="
find_util APKTOOL apktool https://code.google.com/p/android-apktool/
find_util DEX2JAR d2j-dex2jar.sh https://code.google.com/p/dex2jar/
find_util JDGUI jd-gui http://java.decompiler.free.fr/?q=jdgui

echo && echo "== Creating destination directory ============================================="
command mkdir -v "$DST"

echo && echo "== Decoding APK file =========================================================="
command "$APKTOOL" decode --force "$APK" "$DST"

echo && echo "== Extracting DEX from APK file ==============================================="
command unzip "$APK" classes.dex -d "$DST"
command md5 "$DST/classes.dex"
command md5 -q "$DST/classes.dex" > "$DST/classes.dex.md5"

echo && echo "== Converting DEX classes to JAR =============================================="
command "$DEX2JAR" --topological-sort --output "$DST/$APK_BASENAME.jar" "$APK"

echo && echo "== Opening JD-GUI ============================================================="
(command "$JDGUI" "$DST/$APK_BASENAME.jar" &> /dev/null &)

echo && echo "-- Follow futher instructions -------------------------------------------------"
echo "1. Switch to JD-GUI"
echo "2. File -> Save All Sources"
echo "3. Unzip sources file to \"$DST/src\" directory"

echo
echo "Extracted $APK -> $DST"

exit 0