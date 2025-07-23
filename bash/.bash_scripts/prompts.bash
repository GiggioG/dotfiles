arrow='► '
PS1=""
. ~/.bash_scripts/colors.bash
git_status(){
	branch=$(git branch 2> /dev/null | grep '\*' | sed -e 's/* \(.*\)/\1/');
	if [[ "$branch" ]] ; then
		changed=$(git status -s)
		changes="$(git status -s | wc -l)"
		echo -n -e "\b\b";
		if [[ "$changed" ]] ; then
			echo -n -e "${fg_cyan_echo}${bg_red_echo}${arrow}"
			echo -n -e "${fg_white_echo}"
			echo -n -e "${branch} ${changes}"
			echo -n -e "${fg_red_echo}${bg_magenta_echo}${arrow}"
		else
			echo -n -e "${fg_cyan_echo}${bg_green_echo}${arrow}"
			echo -n -e "${fg_white_echo}"
			echo -n -e "${branch}"
			echo -n -e "${fg_green_echo}${bg_magenta_echo}${arrow}"
		fi;
	fi;
}

# Snippet from https://github.com/victorbrca/powerline-simple/blob/7e266751a68aa50c4fcf1ced81cba2e6c5179800/powerline-simple.bash#L24
sudo_status () {
	sudo -n uptime 2>&1 | grep -q "load"
	if [[ $? -eq 0 ]] ; then
		echo -n "☼ "
	fi
}

PS1+="${fg_black}${bg_white}"
PS1+="\u"

PS1+="${fg_white}${bg_bblack}${arrow}"

PS1+="${fg_white}${bg_bblack}"
PS1+="\h"

PS1+="${fg_bblack}${bg_cyan}${arrow}"

PS1+="${fg_black}${bg_cyan}"
PS1+="\w"

PS1+="${fg_cyan}${bg_magenta}${arrow}"

PS1+="\$(git_status)"

PS1+="${fg_white}${bg_magenta}"
PS1+="\$(sudo_status)"
PS1+="\$"

PS1+="${ansi_clear}${fg_magenta}${arrow}${ansi_clear}"
