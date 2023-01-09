#!/bin/bash

# Copyright (c) 2023 Robert LaRocca https://www.laroccx.com

# Remove history files created using the GNU History Library.

# Script version and release
script_version='2.5.0'
script_release='beta'  # options devel, beta, release, stable

require_root_privileges() {
	if [[ "$(whoami)" != "root" ]]; then
			# logger -i "Error: clean must be run as root!"
			echo "Error: clean must be run as root!" >&2
			exit 2
	fi
}

show_help_message() {
	cat <<-EOF_XYZ
	Usage: clean [OPTION] [TIME] [WALL]...
	Remove all the known history files in the user home directory.

	Options:
	 all - remove all history files
	 most - remove most history files

	 exit - clean and terminate the current shell session
	 halt - clean and halt
	 reboot - clean and reboot
	 poweroff - clean and poweroff
	 shutdown - clean and shutdown
	 config - add required enviroment variables to shell session

	 version - show version information
	 help - show this help message

	The second argument must be a [TIME] string. The default value
	is 'now' which is interpeted as '+0'. This may be followed with
	a [WALL] message. If included the message will be broadcasted
	to users before shutdown.

	Examples:
	 clean -a
	 clean exit
	 clean reboot now
	 clean poweroff +5 "shutdown initiated by clean.sh"

	History files:
	 ansible
	 bash_history
	 bash_sessions
	 lesshst
	 mysql_history
	 python_history
	 viminfo
	 wget-hsts
	 zsh_history

	Exit status:
	 0 - ok
	 1 - minor issue
	 2 - serious error

	Copyright (c) $(date +%Y) Robert LaRocca, https://www.laroccx.com
	License: The MIT License (MIT)
	Source: https://github.com/robertlarocca/clean-command-history
	EOF_XYZ
}

show_version_information() {
	cat <<-EOF_XYZ
	clean $script_version-$script_release
	Copyright (c) $(date +%Y) Robert LaRocca, https://www.laroccx.com
	License: The MIT License (MIT)
	Source: https://github.com/robertlarocca/clean-command-history
	EOF_XYZ
}

error_unrecognized_option() {
	cat <<-EOF_XYZ
	clean: unrecognized option '$1'
	Try 'clean --help' for more information.
	EOF_XYZ
	exit 1
}

remove_all_history() {
	rm -f $HOME/.bash_history
	rm -f $HOME/.lesshst
	rm -f $HOME/.mysql_history
	rm -f $HOME/.python_history
	rm -f $HOME/.selected_editor
	rm -f $HOME/.sudo_as_admin_successful
	rm -f $HOME/.viminfo
	rm -f $HOME/.wget-hsts
	rm -f $HOME/.zsh_history
	rm -rf $HOME/.ansible
	rm -rf $HOME/.bash_sessions
	history -c
	clear
}

remove_most_history() {
	rm -f $HOME/.bash_history
	rm -f $HOME/.lesshst
	rm -f $HOME/.mysql_history
	rm -f $HOME/.python_history
	rm -f $HOME/.wget-hsts
	rm -f $HOME/.zsh_history
	rm -rf $HOME/.bash_sessions
	history -c
	clear
}

configure_enviroment_variables() {
	local clean_binary="$(which clean)"

	cat <<-EOF_XYZ | sudo tee /etc/profile.d/clean.sh
	if [ -x "$clean_binary" ]; then
		. $clean_binary
	fi
	EOF_XYZ

	cat <<-EOF_XYZ | sudo tee /etc/profile.d/clean.csh
	if [ -x "$clean_binary" ]; then
		. $clean_binary
	fi
	EOF_XYZ

	cat <<-EOF_XYZ | sudo tee -a /etc/bash.bashrc

	# clean script
	if [ -x "$clean_binary" ]; then
		. "$clean_binary"
	fi
	EOF_XYZ
}

# Options
clean() {
	case "$1" in
	all)
		remove_all_history
		;;
	most)
		remove_most_history
		;;
	exit)
		remove_most_history
		exit 0
		;;
	halt)
		remove_most_history
		if [[ -z "$2" ]]; then
			/usr/bin/sudo shutdown --halt +0
		else
			/usr/bin/sudo shutdown --halt "$2" "$3"
		fi
		;;
	reboot)
		remove_most_history
		if [[ -z "$2" ]]; then
			/usr/bin/sudo shutdown --reboot +0
		else
			/usr/bin/sudo shutdown --reboot "$2" "$3"
		fi
		;;
	poweroff)
		remove_most_history
		if [[ -z "$2" ]]; then
			/usr/bin/sudo shutdown --poweroff +0
		else
			/usr/bin/sudo shutdown --poweroff "$2" "$3"
		fi
		;;
	shutdown)
		remove_most_history
		if [[ -z "$2" ]]; then
			/usr/bin/sudo shutdown --poweroff +0
		else
			/usr/bin/sudo shutdown --poweroff "$2" "$3"
		fi
		;;
	config)
		configure_enviroment_variables
		;;
	version)
		show_version_information
		;;
	help | --help)
		show_help_message
		;;
	*)
		if [[ -z "$1" ]]; then
			remove_most_history
		else
			error_unrecognized_option "$1"
		fi
		;;
	esac
}

# vi: syntax=sh ts=4 noexpandtab
