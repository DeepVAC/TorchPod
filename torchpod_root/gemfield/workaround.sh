#!/bin/bash
echo "apply workaound......"

#code
mkdir -p $HOME/.local/share/applications/
cp /gemfield/code.desktop "$HOME/.local/share/applications/code.desktop"

#autostart
mkdir -p $HOME/.config/autostart
echo "configure kde autostart......"
cp /gemfield/wireplumber.desktop "$HOME/.config/autostart/wireplumber.desktop"
cp /gemfield/pipewire.desktop "$HOME/.config/autostart/pipewire.desktop"
cp /gemfield/pipewire-pulse.desktop "$HOME/.config/autostart/pipewire-pulse.desktop"