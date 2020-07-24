# Level Design

As a player, I want to be able play through the game endlessly. I also want to be able to share any run with a friends and let them try to beat my high score. 

To introduce endless mode we need to be able to dynamically create deterministic levels.  Levels have many factors that make them interesting and challenging.  The deeper (further they progress) the player goes through the game the more challenging the levels become.  The factors that determine the challenge level are:
- the number of different rock colors
- the size of the board
- the number of monsters
- the damage multiplier on monsters
- the types of monsters
- the number of pillars
- the placement of pillars
- the goals 
- the number of hazards

Currently, we use a LevelCoordinator to move between three main scenes, the Main Menu, the Game and the Store.  The level coordinator takes care of most scene navigating after the initial load of GameViewController.  The problem with the current set up is that we rely on having an array of levels in memory to traverse through.  Another issue is that we couple the level and the store offers.  Also, we create store offers at the beginning of the run and ignore the player's current inventory.

The recommended solution is to dynamically create levels and store offers so that we can create an endless mode and take the player's inventory into account before making store offers.

The LevelCoordinator responsibility will become more narrow and only coordinate the scenes in the actual run. This means the Game scene and the Store scene. We will also create a Menu coordinator that will be resposible for navigating between menus out side the game, this includes the Main Menu and any other scenes or views that take place out side of the game (credits, high scores, settings, achievements, and unlocks)

## LevelCoordinator
### Responsibilities
- Navigate from Game scene to Store scene
- Calls to create Level and Store Offers dynamically
- Encodes and Decodes Level, Store Offers, and other run specific data 
### Dependencies
- The loaded player's entity data
- The entities json file
- The unlocked resources
- A random seed 


## Menu Coordinator
### Responsibilities
- Passes pertinent information to the Level Cooridnator
- Navigates between menus
- Encodes and decodes any profile specific data (unlocks, settings, achievements)
### Dependencies
- a profile manager
	- achievements, high scores, unlocks, etc
- saved user settings (likely should be device-specific)




