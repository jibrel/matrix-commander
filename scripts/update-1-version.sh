#!/bin/bash

FN="matrix_commander/matrix_commander.py"
VERSION_FILE="VERSION"
MINOR="0"

if ! [ -f "$FN" ]; then
    FN="../$FN"
    if ! [ -f "$FN" ]; then
        echo -n "ERROR: $(basename -- "$FN") not found. "
        echo "Neither in local nor in parent directory."
        exit 1
    fi
fi

if ! [ -f "$FN" ]; then
    echo "ERROR: File \"$FN\" not found."
    exit 1
fi

if [ "${1,,}" == "-m" ] || [ "${1,,}" == "--minor" ]; then
    echo "Doing only a MINOR version increment."
    MINOR="1"
fi

PREFIX="VERSION = "
REGEX="^${PREFIX}\"20[0-9][0-9]-[0-9][0-9]-[0-9][0-9].*\""
COUNT=$(grep --count -e "$REGEX" $FN)
if [ "$COUNT" == "1" ]; then
    # NEWVERSION="$PREFIX\"$(date +%Y-%m-%d-%H%M%S)\""
    NEWVERSION="$PREFIX\"$(date +%Y-%m-%d)\""
    sed -i "s/$REGEX/$NEWVERSION/" $FN
    RETURN=$?
    if [ "$RETURN" == "0" ]; then
        echo "SUCCESS: Modified file $FN by setting version to $NEWVERSION."
    else
        echo "ERROR: could not change version to $NEWVERSION in $FN."
        exit 1
    fi
else
    echo "Error while searching for $REGEX"
    grep -e "$PREFIX" $FN
    if [ "$COUNT" == "1" ]; then
        echo "ERROR: Version not found, expected 1 occurance."
    else
        echo "ERROR: Version found $COUNT times, expected 1 occurance."
    fi
    exit 1
fi

PREFIX="VERSIONNR = "
REGEX="^${PREFIX}\"[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\""
COUNT=$(grep --count -e "$REGEX" $FN)
if [ "$COUNT" == "1" ]; then
    NR=$(grep -e "$REGEX" $FN | cut -d'"' -f2)
    A=$(echo $NR | cut -d'.' -f1)
    M=$(echo $NR | cut -d'.' -f2)
    Z=$(echo $NR | cut -d'.' -f3)
    if [ "$MINOR" == "1" ]; then
        Z=$((Z + 1))
    else
        M=$((M + 1))
        Z="0"
    fi
    NEWVERSIONNR="${A}.${M}.${Z}"
    echo $NEWVERSIONNR >"$VERSION_FILE"
    NEWVERSION="$PREFIX\"${A}.${M}.${Z}\""
    sed -i "s/$REGEX/$NEWVERSION/" $FN
    RETURN=$?
    if [ "$RETURN" == "0" ]; then
        echo "SUCCESS: Modified file $FN by setting version to $NEWVERSION."
    else
        echo "ERROR: could not change version to $NEWVERSION in $FN."
        exit 1
    fi
else
    echo "Error while searching for $REGEX"
    grep -e "$PREFIX" $FN
    if [ "$COUNT" == "1" ]; then
        echo "ERROR: Version not found in $FN, expected 1 occurance."
    else
        echo "ERROR: Version found $COUNT times in $FN, expected 1 occurance."
    fi
    exit 1
fi

# update PyPi setup file
# version = 2.1.0
FN="setup.cfg"
if ! [ -f "$FN" ]; then
    echo "ERROR: File \"$FN\" not found."
    exit 1
fi
PREFIX="version = "
REGEX="^${PREFIX}[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*"
COUNT=$(grep --count -e "$REGEX" $FN)
if [ "$COUNT" == "1" ]; then
    NEWVERSION="${PREFIX}${NEWVERSIONNR}"
    sed -i "s/$REGEX/$NEWVERSION/" $FN
    RETURN=$?
    if [ "$RETURN" == "0" ]; then
        echo "SUCCESS: Modified file $FN by setting version to $NEWVERSION."
    else
        echo "ERROR: could not change version to $NEWVERSION in $FN."
        exit 1
    fi
else
    echo "Error while searching for $REGEX"
    grep -e "$PREFIX" $FN
    if [ "$COUNT" == "1" ]; then
        echo "ERROR: Version not found in $FN, expected 1 occurance."
    else
        echo "ERROR: Version found $COUNT times in $FN, expected 1 occurance."
    fi
    exit 1
fi

exit 0
