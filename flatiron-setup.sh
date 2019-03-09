#!/usr/bin/env bash

# get all the input at the start for those UX points
echo "Please ensure you are connected to wifi!"
source ./checker_strings.sh

read -p "Enter github email: " email
read -p "Enter fullname: " fullname

####################################################
# xcode is by far the hardest part to install automatically. So I've skipped it.
#
# os=$(sw_vers -productVersion | awk -F. '{print $1 "." $2}')
# if softwareupdate --history | grep --silent "Command Line Tools.*${os}"; then
#     echo 'Command-line tools already installed.'
# else
#     echo 'Installing Command-line tools...'
#     in_progress=/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
#     touch ${in_progress}
#     product=$(softwareupdate --list | awk "/\* Command Line.*${os}/ { sub(/^   \* /, \"\"); print }")
#     softwareupdate --verbose --install "${product}" || echo 'Installation failed.' 1>&2 && rm ${in_progress} && exit 1
#     rm ${in_progress}
#     echo 'Installation succeeded.'
# fi
######################################################

# homebrew
if ! eval $check_brew; then
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  brew update
  echo "you now have homebrew"
fi


# general brew packages
function install_or_upgrade { brew ls | grep $1 > /dev/null; if (($? == 0)); then brew upgrade $1; else brew install $1; fi }
install_or_upgrade "git"
install_or_upgrade "wget"
install_or_upgrade "imagemagick"
install_or_upgrade "jq"
install_or_upgrade "openssl"
install_or_upgrade "gmp"
install_or_upgrade "gnupg"
install_or_upgrade "sqlite"

echo "you now have homebrew lvl 2"

# lets have some rvm fun
eval $check_rvm
if (($? == 1)); then
  curl -sSL https://get.rvm.io | bash
  # work around so you dont have to close and reopen terminal
  if [[ -s "$HOME/.rvm/scripts/rvm" ]]; then
    . "$HOME/.rvm/scripts/rvm"
  else
    echo "$HOME/.rvm/scripts/rvm" could not be found.
    exit 1
  fi
  export PATH="$PATH:$HOME/.rvm/bin"
  echo "you now have rvm (that's ruby version manager)"
fi

####################################################################
# Ruby version
#
# Current flatiron version
vers=2.3.3
#
# Or keep up to date!!
# A technique to find the latest stable version of ruby.
# html = Net::HTTP.get(URI("https://www.ruby-lang.org/en/downloads/"))
# vers = html[/http.*ruby-(.*).tar.gz/,1]
####################################################################


if ! eval $check_ruby_version; then
  # necessary for rvm to become a shell function, and so to run rvm use...
  source  ~/.rvm/scripts/rvm
  rvm use $vers --default --install
  echo "you now have ruby $vers. Yay!"
fi

# we love gems.
gem update --system
gem install learn-co bundler json rspec pry pry-byebug nokogiri hub thin shotgun rack hotloader rails sinatra --no-document
echo "you now have ruby with gems!!"

# need to do github stuff
git config --global user.email $email
git config --global user.name $fullname

# Cask for slack, google and atom
eval $check_cask && brew install caskroom/cask/brew-cask
eval $check_atom && brew cask install atom

eval $check_nvm
if (( $? == 1)); then
  curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | bash
  echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bash_profile
  echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"' >> ~/.bash_profile
  source ~/.bash_profile
fi

eval $check_chrome && brew cask install google-chrome
eval $check_slack && brew cask install slack

echo "Cask that task"

# node stuff
if ! eval $check_node; then
  nvm install node
  nvm use node
  nvm alias default node
fi

# postgres
if ! eval $check_postgres
  brew install postgresql
  ln -sfv /usr/local/opt/postgresql/*.plist ~/Library/LaunchAgents
  export alias pg_start="launchctl load ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist"
  pg_start
fi

# This script is far from perfect. Check it.
curl -so- https://raw.githubusercontent.com/Voxoff/flatiron-manual-setup/master/flatiron-setup-checker.sh | bash 2> /dev/null
echo "This script does not run 'learn whoami'"
