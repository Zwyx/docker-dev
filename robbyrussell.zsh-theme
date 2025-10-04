PR_FILLBAR="\${(l:$(( COLUMNS - 27 ))::─:)}"
PR_TITLE="┌───── Docker Dev $PR_FILLBAR"

PROMPT="
%(?:%{$FG[209]%}$PR_TITLE:%{$fg_bold[red]%}$PR_TITLE) %{$FG[242]%}%*
%(?:%{$FG[209]%}└➜ :%{$fg_bold[red]%}└➜ ) %{$fg[cyan]%}%c%{$reset_color%}"
PROMPT+=' $(git_prompt_info)'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}git:(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}✗"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"
