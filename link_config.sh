#!/bin/bash

# Script to create symlinks from ./config/ directories to ~/.config/
set -e
CONFIG_SOURCE_DIR="$(realpath ./config)"
CONFIG_TARGET_DIR="$HOME/.config"

echo "Source directory: $CONFIG_SOURCE_DIR"
echo "Target directory: $CONFIG_TARGET_DIR"
echo ""

if [ ! -d "$CONFIG_SOURCE_DIR" ]; then
    echo "Error: Source directory $CONFIG_SOURCE_DIR does not exist"
    exit 1
fi
mkdir -p "$CONFIG_TARGET_DIR"

# First, remove symlinks for directories that no longer exist in ./config/
echo "Cleaning up orphaned symlinks..."
for target_link in "$CONFIG_TARGET_DIR"/*; do
    if [ -L "$target_link" ]; then
        dir_name=$(basename "$target_link")
        source_dir="$CONFIG_SOURCE_DIR/$dir_name"

        if [ ! -d "$source_dir" ]; then
            rm "$target_link"
            echo "✗ $dir_name - symlink removed (source directory not found)"
        fi
    fi
done
echo ""

# Iterate through each directory in ./config/
echo "Linking directories..."
for config_dir in "$CONFIG_SOURCE_DIR"/*; do
    if [ ! -d "$config_dir" ]; then
        continue
    fi

    dir_name=$(basename "$config_dir")
    target_link="$CONFIG_TARGET_DIR/$dir_name"

    if [ -e "$target_link" ]; then
        if [ -L "$target_link" ]; then
            # It's already a symlink
            existing_target=$(readlink "$target_link")
            if [ "$existing_target" = "$config_dir" ]; then
                echo "✓ $dir_name - symlink already exists and points to correct location"
            else
                echo "⚠ $dir_name - symlink exists but points to: $existing_target"
                echo "  Skipping to avoid overwriting"
            fi
        else
            # It's a regular file/directory
            echo "⚠ $dir_name - already exists as a regular file/directory"
            echo "  Skipping to avoid overwriting"
        fi
    else
        echo "Linking $dir_name..."
        # Create the symlink
        ln -s "$config_dir" "$target_link"
        echo "✓ $dir_name - symlink created"
    fi
done

echo ""
echo "Done!"
