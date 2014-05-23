#!/bin/sh

# Set GIT configuration information

cd "$SRCROOT"

git=`sh /etc/profile; which git`

count=`$git rev-list HEAD | wc -l | xargs`

echo "// Auto generated from lib/preprocessor_prefix.sh" > lib/preprocessor_prefix.h
echo "#define GIT_COMMIT_COUNT $count" >> lib/preprocessor_prefix.h
