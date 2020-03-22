echo "СТАНДАРТНІ ЗМІНІН:"
echo "HOME: $HOME"
echo "IFS: $IFS"
echo "MAIL: $MAIL"
echo "MAILCHECK: $MAILCHECK"
echo "MAILPATH: $MAILPATH"
echo "SHACCT: $SHACCT"
echo "SHELL: $SHELL"
echo "PATH: $PATH"
echo "PS1: $PS1"
echo 

echo "СПЕЦІАЛЬНІ ЗМІННІ:"
echo_args(){
    echo "\$# (кількість аргументів): $#"
}
echo_args a b c
echo "\$$ (номер поточного процесу): $$"
echo "\$! (номер останньного процесу): $!"
echo 
echo "ЗМІННІ КОРИСТУВАЧА:"
echo_var0() {
    echo "VAR0=$VAR0"
}
echo_var0
VAR0=123 echo_var0
echo_var0
VAR0=456
echo_var0
export VAR0=000
echo_var0

echo 
echo 'Файл ~/.profile'
cat ~/.profile
echo 'Допишемо щось'
echo 'export VAR0=123' >> ~/.profile
cat ~/.profile