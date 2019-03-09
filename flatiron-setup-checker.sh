#!/bin/sh

###########################################################################
# Credit to Hysan for this script. Copied and changed from original #
###########################################################################


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

evaluate () {
  eval $1
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
  local result=$(evaluate "$2")
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


## 2. Install Xcode Command Line Tools
# https://apple.stackexchange.com/questions/219507/best-way-to-check-in-bash-if-command-line-tools-are-installed
# https://stackoverflow.com/questions/15371925/how-to-check-if-command-line-tools-is-installed
# https://stackoverflow.com/questions/21272479/how-can-i-find-out-if-i-have-xcode-commandline-tools-installed
print_table_results "Xcode Command Line Tools" 'type xcode-select >&- && xpath=$( xcode-select --print-path ) && test -d "${xpath}" && test -x "${xpath}"'
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
print_table_results "Default RVM (2.3.3)" $check_rvm_v
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
print_table_results "Learn Editor" $check_atom_editor
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
print_table_results "Installed Rails" $check_rail
print_table_results "Gem: rails" $check_rails_gem
delimiter

## 14. Node Version Manager (nvm)
# https://unix.stackexchange.com/questions/184508/nvm-command-not-available-in-bash-script
# https://stackoverflow.com/questions/39190575/bash-script-for-changing-nvm-node-version
. ~/.nvm/nvm.sh
print_table_results "Installed NVM" $check_nvm
print_table_results "Installed Node" $check_node
print_table_results "Default Node (11.x)" 'command -v nvm >/dev/null 2>&1 && nvm version default | grep -q "v11"'
delimiter

## 16. Google Chrome
# https://unix.stackexchange.com/questions/63387/single-command-to-check-if-file-exists-and-print-custom-message-to-stdout
print_table_results "Installed Google Chrome" $check_chrome
delimiter

## 17. Slack
print_table_results "Installed Slack" $check_slack
delimiter


## Student Configuration
configuration_header
delimiter

## 5. git
echo "Github"
print_data_row "Username" $check_git_config_username
print_data_row "Email" $check_git_config_email
delimiter

## 9. Learn
# https://stackoverflow.com/questions/369758/how-to-trim-whitespace-from-a-bash-variable
echo "Learn"
print_data_row "Name" $check_learn_name
print_data_row "Username" $check_learn_username
print_data_row "Email" $check_learn_email
delimiter
