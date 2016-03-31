#!/bin/bash

set -e

# Script to install Xcode w/ CLI tools on a fresh OS X 10.11, via applescript.
# Important note: before running script we have to enable assistive touch for terminal

# This might be more lovely (and maintainable) as ruby, if only we could have some handy
# gems that all need a compiler for native extensions. We don't, so do it old school.

# Some things:
#
# * This is handy: http://tldp.org/LDP/abs/html/
# * So is: https://developer.apple.com/library/mac/documentation/<snip>
#   <snip>AppleScript/Conceptual/AppleScriptLangGuide/
# * We need sudo.
# * The creds should be passed as two lines on stdin; this is the most secure way I know.
# * Do not run this script as root.
# * Do not source this script into another (including your current shell.)

function show_help {
cat <<HELP
Usage: echo -e 'user\npass' | $0 please

Scripted installation of Xcode with CLI tools from the App Store.

Unless 'please' is passed, show this help and do nothing.

Otherwise this will look for your apple credentials on two lines in stdin (id on the
first line, then password), which will be verified with Apple.  If nothing is supplied
on stdin, you will be prompted for credentials.

Using support for assistive devices and applescript, the App Store will be opened and
Xcode will be installed.  Xcode will then be opened and license agreement will be
accepted for you: to review that agreement now, visit the url below.  Finally, the
command-line utilities will be installed.

The Xcode license agreement: http://www.apple.com/legal/sla/docs/xcode.pdf

To enable support for assisitive devices, you may be prompted for your administrator
(sudo) password.
HELP
}

# Show the given message and exit with status 1.
function die {
  echo -e "Error: $*"
  exit 1
}

# Show the given message, followed by help, and exit with status 1.
function die_help {
  echo -e "Error: $*"
  echo
  show_help
  exit 1
}

[[ "$USER" == root ]] && die_help "Run this as a normal user, I'll sudo when I need to."

# A (very) poor man's headless browser.
#
# We follow redirects and deal with cookies.
#
# The first parameter should be a file for curl to use as a read-write cookie jar.
# Any remaining arguments (at least one more is required) are passed straight to curl.
#
# Since we use perl (HTML::Tree) elsewhere, we might be tempted to use LWP here and drop
# bash completely. However, getting the needed functionality simply (redirects, cookies)
# is apparently beyond the ken of several perlmonk threads.  So curl it is.
function http {
  [[ $# < 2 ]] && die "http helper doesn't understand '$@'"

  local cookies="$1"
  shift 1

  # --silent disables the progress bar
  # --location follows redirects
  # --cookie provides request cookies from the file
  # --cookie-jar writes response cookies back afterwards
  curl                        \
    --silent                  \
    --location                \
    --cookie      "$cookies"  \
    --cookie-jar  "$cookies"  \
    "$@"
}

# Parse the given html content with a bit of perl.
#
# The html should be the first positional parameter.  The perl should be passed on stdin
# (i.e. as an inline heredoc).  It may assume an HTML::Tree named $doc which has parsed
# the content is in scope.
#
# Be sure to use single-quoted heredocs.
function html {
  [[ $# == 1 ]] || die "html helper doesn't understand '$@'"

  # If I try to not buffer stdin before calling perl, something craps the bed and stdin
  # is lost.  So grab it up front and use -e instead.  Pray you don't need newlines.
  local script=$(cat)

  echo "$1" | perl -Mv5.12 -MHTML::Tree \
    -e 'my $doc = HTML::Tree->new();'   \
    -e '$doc->parse_file(\*STDIN);'     \
    -e "$script"
}

# Verify the credentials with Apple.
#
# Do this by simulating a login session to https://appleid.apple.com/.
#
# To acomplish this we use one of the few html parsing APIs available to a fresh 10.8
# install: the HTML::Tree module in perl.
function verify_credentials {
  [[ $# == 2 ]] || die "verify_credentials doesn't understand '$@'"

  # Parse arguments
  local apple_id="$1"
  local apple_password="$2"

  # Create the cookie file.
  local cookie_jar=$(mktemp /tmp/install-xcode.XXXXXX)

  # Try to clean it up on exit.  Note we only get one exit handler per process.
  trap "rm '$cookie_jar'" exit

  # Go to the apple id management app front page.
  local response=$(http "$cookie_jar" 'https://appleid.apple.com/')

  # Find the "Manage your Apple ID" link.
  local url=$(html "$response" <<'PERL'
    # Consider links..
    for ( $doc->look_down('_tag' => 'a') ) {
      # ..whose anchor text matches "Manage your Apple ID"
      say $_->attr('href') if $_->as_text() =~ m/Manage your Apple ID/;
    }
PERL
  )

  # Click it
  response=$(http "$cookie_jar" "$url")

  # Find the signIn field.  Grab its action url as well as all of its fields
  local url_and_query=$(html "$response" <<'PERL'
    use URI::Escape;

    for my $form ( $doc->look_down('_tag' => 'form') ) {
      # Skip anyone with the wrong id
      next unless $form->attr('id') =~ m/signIn/;

      # Grab the url
      say $form->attr('action');

      my @parameters = ();

      # Examine the form's fields to build up a query string to POST
      for my $input ( $form->look_down('_tag' => 'input') ) {
        my $name = uri_escape($input->attr('name'));

        # Skip these two, since we'll do them explictly after
        next if $name =~ m/theAccountName/ || $name =~ m/theAccountPW/;

        if ( defined($input->attr('value')) ) {
          my $value = uri_escape($input->attr('value'));

          push(@parameters, $name . "=" . $value);
        } else {
          push(@parameters, $name);
        }
      }

      # Print the parameters together as one query string
      say join("&", @parameters);

      # Ok, we're done.  Break the loop.
      last;
    }
PERL
  )

  # Parse the url out of the two-line result, (clumsily) resolve relative urls
  url=$(echo "$url_and_query" | head -n 1 | sed 's|^/|https://appleid.apple.com/|')

  # Parse query string out of the two-line result
  local query="$(echo "$url_and_query" | tail -n 1)$creds"

  # "Submit" the form
  response=$(http "$cookie_jar"       \
    -d "$query"                       \
    -d "theAccountName=$apple_id"     \
    -d "theAccountPW=$apple_password" \
    "$url"
  )

  html "$response" <<'PERL'
    for ( $doc->look_down('_tag' => 'a') ) {
      # We failed if we see a forgot password link.
      exit 1 if $_->as_text() =~ m/Forgot your password/;
    }
PERL
}

# Open the App Store and download Xcode.
function download_xcode {
  [[ $# == 2 ]] || die "download_xcode doesn't understand '$@'"

  # Parse arguments
  local apple_id="$1"
  local apple_password="$2"

  # Do we already have Xcode?  We're done!
  [[ -d /Applications/Xcode.app ]] && return 0

  # Open the Xcode page within the App Store
  open 'macappstore://itunes.apple.com/us/app/xcode/id497799835'

  # Give it a moment
  sleep 2
        
  echo -e "$apple_id\n$apple_password" | osascript 3<&0 <<'APPLESCRIPT'
    on run argv
      # Parse arguments
      set stdin to do shell script "cat 0<&3"
      set appleId       to paragraph 1 of stdin
      set applePassword to paragraph 2 of stdin

      tell application "System Events"			tell window "App Store" of process "App Store"				set loaded to false				repeat until loaded = true					try						# There's really no less brittle way I can find to navigate the UI.						# Along with the Accessibility Inspector, "UI elements" is your friend:						# i.e. "tell scroll area 1 to UI elements"						# http://n8henrie.com/2013/03/a-strategy-for-ui-scripting-in-applescript/						# UI element 1 of group 1 of UI element 1 of scroll area 1 of group 1 of group 1						set installButtonContainer to group 1 of group 1 of UI element 1 of scroll area 1 of group 1 of group 1						set installButton to button 1 of installButtonContainer						set loaded to true					on error						delay 1					end try				end repeat						if description of installButton = "Open, Xcode" then					tell application "App Store" to quit					return # It claims to be installed.				end if						if description of installButton = "Installing, Xcode" then					tell application "App Store" to quit					return				end if						if not description of installButton = "Install, Xcode, Free" then					# What page are we looking at?  Is Xcode no longer free?  Bail.					error "Can't find install button."				end if						# Petrov: Sir! The reason for having two keys is so that no one man may...				click installButton						# Give it a moment.				delay 2						# Regrab the reference, since they may have replaced it				set installButton to button 1 of installButtonContainer				# Do we need to confirm?				if description of installButton = "Confirm, Install, Xcode, Free" then					# Ramius: May what, Doctor?					click installButton								# Give it a moment.					delay 2								# Regrab the reference, since they may have replaced it					set installButton to button 1 of installButtonContainer				end if						# Do we need to authenticate?				# If so, we will be looking at a modal pop-down dialog for credentials.				set needToAuthenticate to false				try					# We should now be looking at a modal pop-down dialog for credentials.					set appleIdBox to text field "Apple ID " of sheet 1					set applePasswordBox to text field "Password" of sheet 1					set signInButton to button "Sign In" of sheet 1								set needToAuthenticate to true				on error					# We may not be prompted for creds at all				end try						if needToAuthenticate = true then					# Petrov: Arm the missiles, Captain.					set value of appleIdBox to appleId					set value of applePasswordBox to applePassword								# Give it a moment.					delay 1								# Ramius: Mmm, thank you for your concern Doctor.					click signInButton								# Give it a moment.					delay 10								# Regrab the reference					set installButton to button 1 of installButtonContainer				end if						# Do we need to confirm?				if description of installButton = "Confirm, Install, Xcode, Free" then					# Ramius: May what, Doctor?					click installButton								# Give it a moment.					delay 2								# Regrab the reference, since they may have replaced it					set installButton to button 1 of installButtonContainer				end if						# Another point of confirm to buy				set needToAuthenticate to false				try					# We should now be looking at a modal pop-down dialog for credentials.					set appleIdBox to text field "Apple ID " of sheet 1					set applePasswordBox to text field "Password" of sheet 1					set buyButton to button "Buy" of sheet 1								set needToAuthenticate to true				on error					# We may not be prompted for creds at all				end try						if needToAuthenticate = true then					# Petrov: Arm the missiles, Captain.					set value of appleIdBox to appleId					set value of applePasswordBox to applePassword								# Give it a moment.					delay 1								# Ramius: Mmm, thank you for your concern Doctor.					click buyButton								# Give it a moment.					delay 10								# Regrab the reference					set installButton to button 1 of installButtonContainer				end if						try					click button 1 of sheet 1					delay 10				end try						# At this point it should be downloading				if not description of installButton = "Installing, Xcode" then					error "Could not start install."				end if						# Busy wait..				repeat while description of installButton = "Installing, Xcode"					delay 5					set installButton to button 1 of installButtonContainer				end repeat						if description of installButton = "Install, Xcode, Free" then					error "Install paused or cancelled"				else if not description of installButton = "Installed, Xcode" then					error "Unknown error during installation"				end if			end tell		end tell
      tell application "App Store" to quit
    end run
APPLESCRIPT
}

function main {
  # Assert the only argument is 'please' or show the help and bomb out.
  [[ $# != 1 || "$1" != 'please' ]] && show_help && exit 0

  local apple_id        # The user's apple id from stdin
  local apple_password  # The user's apple password, from stdin

  # Spawn a sudo refresh loop
  #while true
  #do
  #  sudo -v
  #  sleep 30
  #done &

  # Detect interactive shells and either read in the credentials or prompt
  if [ -t 0 ]
  then
    # Interactive
    read    -p 'Apple ID: '       apple_id
    read -s -p 'Apple Password: ' apple_password
    echo
  else
    # Non-interactive
    read apple_id && read apple_password ||
      die_help 'Please pass your apple credentials on standard in.'
  fi

  # Verify the credentials or die
  verify_credentials "$apple_id" "$apple_password" ||
    die 'Could not verify your credentials with Apple.  Sorry!'

  # Ensure Xcode is downloaded
  download_xcode "$apple_id" "$apple_password"


  # Kill the sudo refresh loop
  #kill %1
  #wait
}

main "$@"