#!/usr/bin/env bash

# get all the input at the start for those UX points
echo "Please ensure you are connected to wifi!"

# Xcode is hard to install automatically. It is automatically put into a background process. These are three failed attempts.
# check for xcode, exit and demand install if not present

os=$(sw_vers -productVersion | awk -F. '{print $1 "." $2}')
if softwareupdate --history | grep --silent "Command Line Tools.*${os}"; then
    echo 'Command-line tools already installed.'
else
  echo "Please ensure you have installed xcode before running this script. Run `xcode-select --install`."
  return 1
fi

# info for git config
read -p "Enter github email: " email
read -p "Enter fullname: " fullname

# homebrew
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew update

echo "You now have homebrew"

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

echo "You now have homebrew level 2"

# needs a checker for  Warning: gnupg-1.4.19 --->  brew link gnupg

# lets have some rvm fun
curl -sSL https://get.rvm.io | bash

# work around so you dont have to close and reopen terminal
if [[ -s "$HOME/.rvm/scripts/rvm" ]]; then
  . "$HOME/.rvm/scripts/rvm"
else
  echo "$HOME/.rvm/scripts/rvm" could not be found.
  exit 1
fi

export PATH="$PATH:$HOME/.rvm/bin"

echo "You now have rvm (that's ruby version manager)"

####################################################################
# Ruby version
#
# Current flatiron version
# vers=2.5.3

# Or keep it up to date!!
# A technique to find the latest stable version of ruby.  Currently this script default to 2.6.1 
# html = Net::HTTP.get(URI("https://www.ruby-lang.org/en/downloads/"))
# vers = html[/http.*ruby-(.*).tar.gz/,1]
####################################################################
vers=2.6.1


# necessary for rvm to become a shell function, and so to run rvm use...
source  ~/.rvm/scripts/rvm
rvm use $vers --default --install

echo "you now have ruby $vers. Yay!"

# we love gems.
gem update --system
gem install learn-co bundler puma pg json rspec pry pry-byebug nokogiri hub thin shotgun rack hotloader rails sinatra --no-document

echo "you now have ruby with gems!!"

# need to do github stuff
git config --global user.email $email 
git config --global user.name $fullname

# Cask for slack, google and atom
brew install caskroom/cask/brew-cask
brew cask install atom

echo "Atomified." 

curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | bash
echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bash_profile
echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"' >> ~/.bash_profile
source ~/.bash_profile

brew cask install google-chrome
brew cask install slack

echo "Cask that task"

# node stuff
nvm install node
nvm use node
nvm alias default node

# pg
brew install postgresql
brew services start postgresql
# old way
#ln -sfv /usr/local/opt/postgresql/*.plist ~/Library/LaunchAgents
#export alias pg_start="launchctl load ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist"
#pg_start

# Some people don't want to restart their terminal
source ~/.bashrc

# This script is far from perfect. Check it.
curl -so- https://raw.githubusercontent.com/Voxoff/flatiron-manual-setup/master/flatiron-setup-checker.sh | bash 2> /dev/null
echo "This script does not run 'learn whoami'"
