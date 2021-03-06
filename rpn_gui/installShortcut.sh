#!/bin/bash
echo Starting...
if ! command -v xdg-user-dir &> /dev/null then
then
    echo "Warning: xdg-user-dir not installed on this computer."
    echo "Using explicit ~/Desktop as the Desktop path. This path might not exist on non-English OSes."
    path=~/Desktop
else
    path=`xdg-user-dir DESKTOP`
fi
echo "#!/usr/bin/env xdg-open" > "$path/RPNG.desktop"
echo "[Desktop Entry]" >> "$path/RPNG.desktop"
echo "Version=0.5" >> "$path/RPNG.desktop"
echo "Type=Application" >> "$path/RPNG.desktop"
echo -e "Exec=\"$(pwd)/rpncalculator\"" >> "$path/RPNG.desktop"
echo "Name=RPN Calculator GUI" >> "$path/RPNG.desktop"
echo "Comment=A GUI app of RPN Calculator – PapajScript interpreter." >> "$path/RPNG.desktop"
echo "Icon=$(pwd)/rpncalculator.ico" >> "$path/RPNG.desktop"
if [ -f "$path/RPNG.desktop" ] ; then
	chmod +x "$path/RPNG.desktop"
	echo "The shortcut of RPN Calculator GUI has been created at $path."
else
    echo "Error: cannot create a shortcut at $path."
fi
