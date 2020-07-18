# Profile Management
### Shift Shift
As a player, I want to save my profiles in GameCenter so that I can access them on any devices.  I also want to be able to leave my game at any point and know the progress has been saved. I also want to be able to pick up a saved game and play without any internet connectivity. 

The profile management will take care of all load, saving, and creating of save games.  It will also interface with GameCenter to allow put down and pick up on any device.  

There are two three of first launches.  
1. 	 The player has never played a game on any device
2.	 The player has played a game on another device and is signed in with the same GameCenter account
3.	 " " " and is not signed in to GameCenter or is signed in on a different account that has never played)

We handle these situations in two different ways:

1 & 3) We create a save file for this player and save it to GameCenter and their local device.  

2) We load their save file from GameCenter


There are two type of non-first launches
1. The player is signed in to GameCenter 
2. The player is signed out of GameCenter or lacks internet connectivity.

We handle these
1. We load the player's save file from game center
2. We load the player's save file from device


 ## Saving files
Whenever we save, we send the files to GameCenter and to the local device. The name of the save file is the UUID that we create on first app launch and save to the player's user defaults. The save file represents game data that includes the player's progress and the current state of a run (if they are in a run).

Games are saved in between runs.  When the app leaves memory. And after any progress is made in the game (achievements or unlocks)

If we have saved before then we will need to overwrite the save file.  Prior to overwriting we make sure that the file we are saving has more progress than the file that already exists.  If the progress is the same then we take the file with a timestamp further into the future.  


## Loading files
Whenever we load a file, we first check the GameCenter. Then we check the local device.  

Games are loaded from the game center and then saved locally so we have the most up to date information.

If there are no games in the GameCenter or no network connectivity then we load the local files.  

1. Attempt to load files from GameCenter

1a. Have file, great save it locally to keep everything in sync

2. Attempt to load files from Local

2a. Have file great, save remotely to keep everything in sync

3. No save files exists.  Save file remotely and locally

## Revision strategy
We need to have a way to reconcile remote files and local file collisions.  For example, a player with a ipad and iphone could start playing on iPhone and save the game in Game Center.  That player, with no internet, could start playing on their iPad -- not understanding that we allow all device pick up and play.  If that iPad games connectivity and they are signed into Game Center, then we may have a difference in local files versus remote files.  

(Assume we can measure progress in the game). Lets say on iPhone they progressed 10%. On iPad they progressed 5% and then gained internet connectivity.  Which file, Game Center or iPad Local, should we save. 

As a player, I would not want to lost my progress on the iPhone.  As an engineer I do not want to maintain two save files.

Options:
1. Disable GameCenter on all but one of the devices based on the player's choice and save all files locally.
2. Update the save file(s) with less progress to match the progress on the other device(s) ( iPad 5% -> 10% )
3. Update the save file(s) with more progress to match the progress on the other device(s) ( iPhone 10% -> 5%)
4. Save x files in the GameCenter and allow the player to pick which one to use on app launch


The recommended option is number 2. This allows the player not to lose any progress on their iPhone.  This removes the player's need to replay or unlock certain parts of the game.  This also reduces engineering work by reducing the number of save files a player can have.  

The cons of this approach is that the player may be in the middle of a run or have gems to spend from a previous run when they gain connectivity and we force a relaunch. Other con is that we have to be able to measure progress in a game.  

Potential copy "Shift Shaft has detected a save game in Game Center that has progressed further in the game. Shift Shaft will relaunch with the updated game." 


## Reset data

We should devise a UI to allow the player to reset their data and start a game fresh.  

