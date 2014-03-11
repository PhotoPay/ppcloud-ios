#!/bin/bash

git show-ref --verify --quiet "refs/heads/$1"
if [ $? != 0 ]; then
	echo "Branch doesn't exist, please specify existing branch"
	exit 0
fi

VERSION=$(git describe --abbrev=0)
RELEASE_DIR=../../Releases/iOS/Cloud/$1-$VERSION

if [ -d "$RELEASE_DIR" ]; then
	echo "Release $VERSION for $1 already exists"
	read -p "Press any key to continue packaging..."
fi

mkdir -p "$RELEASE_DIR"

ZIP_NAME="$RELEASE_DIR/ppcloud-ios-$1-$VERSION.zip"

git archive --format zip --output "$ZIP_NAME" $1 

echo "Deployed to $ZIP_NAME"