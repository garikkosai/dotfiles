# Prompt with username with $
# PS1='$USER~$ '

# Date and time wtih color 0;32 is green, 0;36 is cyan
# PS1="\e[0;36m[\d \t] $USER~$ \e[m"

PS1="\[\e[;36m\][\d \t] $USER~ \$ \[\e[m\]"

# Random word generator
alias rw='head -n $[$RANDOM % $(cat /usr/share/dict/words | wc -l)] /usr/share/dict/words | tail -n 1'

# Random password generator with letters(upper and lower) and numbers
# env LC_CTYPE=C fixes tr issue on osx
alias randpass="cat /dev/urandom | env LC_CTYPE=C tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1"

# Mutes volume
alias stfu="osascript -e 'set volume output muted true'"

# Gets current weather for seattle (in celcius...)
alias weather="curl -s 'http://rss.accuweather.com/rss/liveweather_rss.asp?metric=1&locCode=en|us|seattle-wa|98104' | sed -n '/Currently:/ s/.*: \(.*\): \([0-9]*\)\([CF]\).*/\2°\3, \1/p'"

# HTTPServer followed by port
alias httpserver="python -m SimpleHTTPServer"

# Move up N directories
function up {
ups=""
for i in $(seq 1 $1)
do
    ups=$ups"../"
done
cd $ups
}

# Generates a random password
function rp() {
	if [ -z $1 ]; then
		MAXSIZE=10
	else
		MAXSIZE=$1
	fi
	array1=(
	q w e r t y u i o p a s d f g h j k l z x c v b n m Q W E R T Y U I O P A S D
	F G H J K L Z X C V B N M 1 2 3 4 5 6 7 8 9 0
	\! \@ \$ \% \^ \& \* \! \@ \$ \% \^ \& \* \@ \$ \% \^ \& \*
	)
	MODNUM=${#array1[*]}
	pwd_len=0
	while [ $pwd_len -lt $MAXSIZE ]
	do
	    index=$(($RANDOM%$MODNUM))
	    echo -n "${array1[$index]}"
	    ((pwd_len++))
	done
	echo
}

# rename all the files which contain uppercase letters to lowercase in the current folder
function filestolower(){
  read -p "This will rename all the files and directories to lowercase in the current folder, continue? [y/n]: " letsdothis
  if [ "$letsdothis" = "y" ] || [ "$letsdothis" = "Y" ]; then
    for x in `ls`
      do
      skip=false
      if [ -d $x ]; then
	read -p "'$x' is a folder, rename it? [y/n]: " renamedir
	if [ "$renamedir" = "n" ] || [ "$renameDir" = "N" ]; then
	  skip=true
	fi
      fi
      if [ "$skip" == "false" ]; then
        lc=`echo $x  | tr '[A-Z]' '[a-z]'`
        if [ $lc != $x ]; then
          echo "renaming $x -> $lc"
          mv $x $lc
        fi
      fi
    done
  fi
}
