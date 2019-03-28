#!/usr/bin/env bash

##############################################################################################
# Bash script for Flatiron Mac OS set up                                                     #
# Made by Guy Bennett-Jones (London)                                                         #
#                                                                                            #
# http://help.learn.co/technical-support/local-environment/mac-osx-manual-environment-set-up #
#                                                                                            #
##############################################################################################

# extract strings - most are used in both checker script and installer script
check_xcode='type xcode-select >&- && xpath=$( xcode-select --print-path ) && test -d "${xpath}" && test -x "${xpath}"'

check_brew="command -v brew >/dev/null 2>&1"
check_git="command -v git >/dev/null 2>&1 && git version | grep -q 'git version'"
check_git_user="command -v git >/dev/null 2>&1 && git config --list | grep -q 'github.user='"
check_git_email="command -v git >/dev/null 2>&1 && git config --list | grep -q 'github.email='"

check_brew_gmp="command -v brew >/dev/null 2>&1 && brew list | grep -q 'gmp'"
check_brew_gnupg="command -v brew >/dev/null 2>&1 && brew list | grep -q 'gnupg'"

check_rvm="command -v rvm >/dev/null 2>&1 && which rvm | grep -q '/Users/.*/\.rvm/bin/rvm'"
check_ruby_version="command -v rvm >/dev/null 2>&1 && rvm list | grep -Fq '=* ruby-2.6.1 [ x86_64 ]'"
check_rvm_path="command -v rvm >/dev/null 2>&1 && rvm list | grep -Fqv 'Warning! PATH'"

check_learn="command -v gem >/dev/null 2>&1 && gem list | grep -q 'learn-co'"
check_bundler="command -v gem >/dev/null 2>&1 && gem list | grep -q 'bundler'"
check_nokogiri="command -v gem >/dev/null 2>&1 && gem list | grep -q 'nokogiri'"
check_rails_gem="command -v gem >/dev/null 2>&1 && gem list | grep -q 'rails'"
check_rails="command -v rails >/dev/null 2>&1 && rails --version | grep -q 'Rails'"

check_atom="command -v atom >/dev/null 2>&1 && atom -v | grep -q 'Atom'"
check_atom_editor="cat ~/.learn-config | grep ':editor:' | grep -q 'atom'"

check_sqlite3="command -v sqlite3 >/dev/null 2>&1"
check_postgres="command -v postgres >/dev/null 2>&1 && postgres --version | grep -q 'postgres (PostgreSQL)'"
check_psql="command -v psql >/dev/null 2>&1 && psql --version | grep -q 'psql (PostgreSQL)'"

check_nvm="command -v nvm >/dev/null 2>&1 && nvm --version | grep -q '[0-9]*\.[0-9]*\.[0-9]*'"
check_node="command -v node | grep -q '/Users/.*/.nvm/versions/node/v.*/bin/node'"
check_node_version="command -v nvm >/dev/null 2>&1 && nvm version default | grep -q 'v11'"

check_chrome="[ -f /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome ]"
check_slack="[ -f /Applications/Slack.app/Contents/MacOS/Slack ]"

check_git_user_config="command -v git >/dev/null 2>&1 && git config --global user.name"
check_git_email_config="command -v git >/dev/null 2>&1 && git config --global user.email"

check_learn_name="command -v learn >/dev/null 2>&1 && learn whoami | grep 'Name:' | sed 's/Name://g' | sed -e 's/^[[:space:]]*//'"
check_learn_username="command -v learn >/dev/null 2>&1 && learn whoami | grep 'Username:' | sed 's/Username://g' | sed -e 's/^[[:space:]]*//'"
check_learn_email="command -v learn >/dev/null 2>&1 && learn whoami | grep 'Email:' | sed 's/Email://g' | sed -e 's/^[[:space:]]*//'"

echo "Please ensure you are connected to wifi!"
echo "If errors arise, ensure you have run 'xcode-select --install'"

# get all the input at the start for those UX points
echo -n "Enter github email: "
read answer
email=$answer

echo -n "Enter github name: "
read answer
fullname=$answer

# homebrew
if ! eval $check_brew; then
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  brew update
fi

# general brew packages
function install_or_upgrade { brew ls | grep $1 > /dev/null; if (($? == 0)); then brew upgrade $1; else brew install $1; fi }
install_or_upgrade "git"
install_or_upgrade "wget"
install_or_upgrade "gmp"
install_or_upgrade "gnupg"
install_or_upgrade "sqlite"
install_or_upgrade "imagemagick"
install_or_upgrade "jq"
install_or_upgrade "openssl"

####################################################################
# Ruby version
#
# Current flatiron version is 2.6.1
#
# Or if you want to keep up to date!
# A technique to find the latest stable version of ruby.
# html = Net::HTTP.get(URI("https://www.ruby-lang.org/en/downloads/"))
# vers = html[/http.*ruby-(.*).tar.gz/,1]
####################################################################

vers=2.6.1
if ! eval $check_rvm_path; then
  # needed for rvm use
  if [[ -s "$HOME/.rvm/scripts/rvm" ]]; then
    . "$HOME/.rvm/scripts/rvm"
    rvm use $vers
  else
    echo "$HOME/.rvm/scripts/rvm" could not be found. Will proceed to install it.
  fi
fi

if ! eval $check_rvm; then
  curl -sSL https://get.rvm.io | bash
  # work around so you dont have to close and reopen terminal
  if [[ -s "$HOME/.rvm/scripts/rvm" ]]; then
    . "$HOME/.rvm/scripts/rvm"
  else
    echo "$HOME/.rvm/scripts/rvm" could not be found.
  fi
  export PATH="$PATH:$HOME/.rvm/bin"
  echo "You now have rvm (that's ruby version manager)"
fi

if ! eval $check_ruby_version; then
  # necessary for rvm to become a shell function, and so to run rvm use...
  source  ~/.rvm/scripts/rvm
  rvm use $vers --default --install
  echo "You now have ruby $vers. Good move!"
fi

# we love gems.
gem update --system
gems=("learn-co" "bundler" "json" "rspec" "pry" "pry-byebug" "sqlite3" "nokogiri" "hub" "thin" "shotgun" "rack" "hotloader" "rails" "sinatra")
# only install those we don't have. rvm line to ensure gems not installed on macos ruby
source  ~/.rvm/scripts/rvm
for i in ${gems}; do
  ! eval "command -v gem >/dev/null 2>&1 && gem list | grep -q $i" && gem install $i --no-document && echo "installed $i"
done

git config --global user.email $email
git config --global user.name $fullname

# Cask for slack google and atom
! eval $check_atom && brew cask install atom
! eval $check_chrome && brew cask install google-chrome
! eval $check_slack && brew cask install slack

source ~/.nvm/nvm.sh
if ! eval $check_nvm; then
  curl -so- https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | bash
  echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bash_profile
  echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"' >> ~/.bash_profile
  source ~/.bash_profile
fi

if ! eval $check_node; then
  nvm install node
  nvm use node
  nvm alias default node
fi

if ! eval $check_postgres; then
  brew install postgresql
  ln -sfv /usr/local/opt/postgresql/*.plist ~/Library/LaunchAgents
  export alias pg_start="launchctl load ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist"
  pg_start
fi


# Optional stuff. I've left it at the defaults acheivable on the UI in settings.
# Leave this as a comment
# defaults write -g KeyRepeat -int 2
# defaults write -g InitialKeyRepeat -int 15

###################################################################################
# Credit to Michael Cheng for the below script. Copied and changed from original  #
###################################################################################

# https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
NC='\033[0m' # No Color
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'


# https://stackoverflow.com/questions/5615717/how-to-store-a-command-in-a-variable-in-linux
# https://stackoverflow.com/questions/17336915/return-value-in-a-bash-function
# $1 => Command to run
evaluate_test () {
  # https://stackoverflow.com/questions/11193466/echo-without-newline-in-a-shell-script
  eval $1 && printf "${GREEN}pass${NC}\n" || printf "${RED}fail${NC}\n"
}

# $1 => Test Name
# $2 => Command to run
print_table_results () {
  local result=$(evaluate_test "$2")
  # https://stackoverflow.com/questions/6345429/how-do-i-print-some-text-in-bash-and-pad-it-with-spaces-to-a-certain-width
  printf "%-30s => [ %-6s ]\n" "$1" "$result"
}

# $1 => Test Name
# $2 => Command to run
print_data_row () {
  local result=$(eval "$2")
  printf "%-12s => [ %-6s ]\n" "$1" "$result"
}

delimiter () {
  printf "${BLUE}******************************************${NC}\n"
}

validation_header () {
  printf "\n${CYAN}************ VALIDATING SETUP ************${NC}\n\n"
}

configuration_header () {
  printf "\n${CYAN}************* CONFIGURATION **************${NC}\n\n"
}


## Validation
validation_header
delimiter


## 2. Xcode Command Line Tools
# https://apple.stackexchange.com/questions/219507/best-way-to-check-in-bash-if-command-line-tools-are-installed
# https://stackoverflow.com/questions/15371925/how-to-check-if-command-line-tools-is-installed
# https://stackoverflow.com/questions/21272479/how-can-i-find-out-if-i-have-xcode-commandline-tools-installed
print_table_results "Xcode Command Line Tools" $check_xcode
delimiter

## 4. Homebrew
# https://stackoverflow.com/questions/21577968/how-to-tell-if-homebrew-is-installed-on-mac-os-x
# https://stackoverflow.com/questions/592620/how-to-check-if-a-program-exists-from-a-bash-script
print_table_results "Homebrew" $check_brew
delimiter

## 5. git
# https://stackoverflow.com/questions/12254076/how-do-i-show-my-global-git-config
print_table_results "Installed git" $check_git
print_table_results "Github user config" $check_git_user
print_table_results "Github email config" $check_git_email
delimiter

## 6. Support Libraries
print_table_results "Installed gmp" $check_gmp
print_table_results "Installed gnupg" $check_gnupg
delimiter

## 7. Ruby Version Manager (rvm)
print_table_results "Installed RVM" $check_rvm
print_table_results "Default RVM (2.6.1)" $check_ruby_version
print_table_results "Test RVM PATH" $check_rvm_path
delimiter

## 8. Gems
print_table_results "Gem: learn-co" $check_learn
print_table_results "Gem: bundler" $check_bundler
delimiter

## 9. Learn
## See Student Configuration section.

## 10. Atom
print_table_results "Installed Atom" $check_atom
# This script does not run learn whoami
# print_table_results "Learn Editor" $check_atom_editor
delimiter

## 11. Gems (more)
print_table_results "Gem: nokogiri" $check_nokogiri
delimiter

## 12. Databases
print_table_results "Installed sqlite" $check_sqlite
print_table_results "Installed PostgreSQL" $check_postgresql
print_table_results "Installed psql" $check_psql
delimiter

## 13. Rails
print_table_results "Installed Rails" $check_rails
print_table_results "Gem: rails" $check_rails_gem
delimiter

## 14. Node Version Manager (nvm)
# https://unix.stackexchange.com/questions/184508/nvm-command-not-available-in-bash-script
# https://stackoverflow.com/questions/39190575/bash-script-for-changing-nvm-node-version
source ~/.nvm/nvm.sh
print_table_results "Installed NVM" $check_nvm
print_table_results "Installed Node" $check_node
print_table_results "Default Node (11.x)" $check_node_version
delimiter

## 16. Google Chrome
# https://unix.stackexchange.com/questions/63387/single-command-to-check-if-file-exists-and-print-custom-message-to-stdout
# Cant put this in a variable because it escapes the [] and I have no time
print_table_results "Installed Google Chrome" "[ -f /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome ] && /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --version | grep -q 'Google Chrome'"
delimiter

## 17. Slack
# Cant put this in a variable because it escapes the [] and I have no time
print_table_results "Installed Slack" "[ -f /Applications/Slack.app/Contents/MacOS/Slack ] && /Applications/Slack.app/Contents/MacOS/Slack --version | grep -q ''"
delimiter


## Student Configuration
configuration_header
delimiter

## 5. git
echo "Github"
print_data_row "Username" "$check_git_user_config"
print_data_row "Email" "$check_git_email_config"
delimiter

## 9. Learn
# https://stackoverflow.com/questions/369758/how-to-trim-whitespace-from-a-bash-variable
echo "Learn"
print_data_row "Name" $check_learn_name
print_data_row "Username" $check_learn_username
print_data_row "Email" $check_learn_email
delimiter

echo 'Remember to run learn whoami AND set up ssh'
