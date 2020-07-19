# Profile Management
### Shift Shift
As a player, I want to save my profiles in GameCenter so that I can access them on any devices.  I also want to be able to leave my game at any point and know the progress has been saved. I also want to be able to pick up a saved game and play without any internet connectivity. 

We will leverage GameCenter to access save files across devices.  We will leverage the App Sandbox Documents director to save files locally.  

The profile management will take care of all load, saving, and creating of save games.  It will also interface with GameCenter to allow put down and pick up on any device.  

To cut down on the scope of this feature, we will remove the ability to save multiple profiles.  The pros are that we can create a less comlicated UI and remove a lot of complexity when naming files and when deciding what to overwrite. The cons are that a player can only have 1 profile at a time.  

At any point a player should be able to reset their data.  This will reset their progress in the game including: base stats, unlocked runs, stats and achievements.


### Game Center
 We will only use GameCenter to use iCloud to save files across devices.  To use GameCenter, the app has lsted GameCenter as a capability. To use iCloud we have registered iCloud as a app capability and registered a iCloud domain in App Store Connect.

On app launch, we will attempt to authenicate with GameCenter. If the user doesn't have GameCenter, we will fall back and use a local directory to persist data.  If the user needs to authenicate (sign into ) GameCenter, we will display the Game Center sign in view controller and allow Apple to handle that flow.  On complete of that flow or if the player if already signed in, we immediately fetched the save file and load its contents into memory.

### Local Directory
Every player will have a local version of their profile saved.  The profile will be saved as JSON encoded data file in the App's Document directory.  The file name is a UUID that is only created once and then saved to User Defaults.  

On app launch, we will attempt to load the file's content into memory.  

### Profile Resolution
For any player that use GameCenter, there will be two files simultaneously loaded into memory.  We will resolve conflicts by using the profile that has progressed further in the game.  If the profiles have the same progression, we will use the Game Center profile.

Following choosing which file to use.  We will save the file locally and try to save remotely in Game Center.  

### User Defaults
On initial app launch, we create a string reprentation of a UUID as save that to user defaults.  This UUID is the name of the file saved locally and set as the name property on the Profile object.

### App Foreground
This has yet to be implemented, but we would always check for updated data remotely on app foreground.

### Played before but on another device.
It is possible that a player has played on another device before installing the app on a different iOS or iPadOS device.  In this case we will attempt to download the file from Game Center, save that file locally, and go from there.

It is also possible that this player has not enabled Game Center, in this case they will have to start from scratch.


