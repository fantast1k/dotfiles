# Re/Installing OS X from scratch

# Prerequisites

## Backup your files
At first since installation at some point could go wrong be sure that you have back up all your needed information such like Music, Photos, Videos, Documents, Downloads, Passwords, Bookmarks and many others you think it's hard to restore.
For developers: be sure that you also back up you ssh keys and certificates

## Deauthorize iTunes
You need to deauthorize iTunes because Apple allow you to have up to 5 devices for iTunes and if you don't deauthorize your account it be counted as like your OS X is still persist in the world.
To have these done you need to open iTunes and login into iTunes Store, then once it done on menu bar for iTunes you could find tab *Store* and submenu *Deauthorize This Computer* - you need to just press it and that it.

## Donwload fresh OS X
Go to AppStore app and search for `OS X` and just download it, if the app asks about that you're using a newer version just continue - we need to installation dmg file to go further.

## Preparing USB stick for OS X image
Use following script `prepare_for_install.sh` and dont' forget to add execute rights for it using `chmod +x prepare_for_install`. Mine example of usage this script looks like where the first argument is Installer name under `/Applications` directory and the second argument is name of Volume you want to install to.
```bash
prepare_for_install.sh 'Install OS X El Capitan' 'Untitled'
```