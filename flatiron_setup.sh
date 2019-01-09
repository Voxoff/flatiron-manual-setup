#!/usr/bin/env bash

# get all the input at the start for those UX points
read -p "Enter github email: " email
read -p "Enter fullname: " fullname

# xcode is by far the hardest part to install automatically. Errors in the script will most likley arise from this.
# xcode-select --install && sleep 2
# osascript -e 'tell application "System Events"' -e 'tell process "Install Command Line Developer Tools"' -e 'keystroke return' -e 'click button "Agree" of window "License Agreement"' -e 'end tell' -e 'end tell'

os=$(sw_vers -productVersion | awk -F. '{print $1 "." $2}')
if softwareupdate --history | grep --silent "Command Line Tools.*${os}"; then
    echo 'Command-line tools already installed.' 
else
    echo 'Installing Command-line tools...'
    in_progress=/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    touch ${in_progress}
    product=$(softwareupdate --list | awk "/\* Command Line.*${os}/ { sub(/^   \* /, \"\"); print }")
    softwareupdate --verbose --install "${product}" || echo 'Installation failed.' 1>&2 && rm ${in_progress} && exit 1
    rm ${in_progress}
    echo 'Installation succeeded.'
fi

echo "you now have xcode :)"

# homebrew
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew update

echo "you now have homebrew"

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

echo "you now have homebrew level 2"

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

echo "you now have rvm (that's ruby version manager)"

# To void the OpenSSL dependency error
# rwm use 2.3.3 --default --install
rvm use 2.5.3 --default --install

echo "you now have ruby 2.5.3. Yay!"

# we love gems.
gem update --system
gem install learn-co bundler json rspec pry pry-byebug nokogiri hub thin shotgun rack hotloader rails sinatra --no-document

echo "you now have ruby with gems!!"

# leaving this because it requires input 
# learn whoami

echo "Learn. Love. Code"

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
ln -sfv /usr/local/opt/postgresql/*.plist ~/Library/LaunchAgents
export alias pg_start="launchctl load ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist"
pg_start

# This script is far from perfect. Check it.
curl -so- https://raw.githubusercontent.com/hysan/flatiron-manual-setup-validator/master/manual-setup-check.sh | bash 2> /dev/null
echo "This script does not run 'learn whoami'"
