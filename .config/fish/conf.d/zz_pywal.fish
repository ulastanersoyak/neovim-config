if test -f ~/.cache/wal/colors.fish
    source ~/.cache/wal/colors.fish
    set -l acc (string replace '#' '' (sed -n 5p ~/.cache/wal/colors))
    set -g fish_color_command $acc --bold
    set -g fish_color_cwd $acc
    set -g fish_color_end $acc
    set -g fish_color_redirection $acc
    set -g fish_color_operator $acc
    set -g fish_color_escape $acc
end
