DECLARE FUNCTION canWalkTo! (x AS INTEGER, y AS INTEGER)
DECLARE SUB generateLevel (levelIndex AS INTEGER)
DECLARE SUB intro ()
DECLARE SUB showMap ()
DECLARE SUB showStatus ()
DECLARE SUB timeStep ()
DECLARE SUB movePlayer ()
DECLARE SUB moveCreature (index AS INTEGER)
DECLARE SUB update ()
DECLARE SUB showPlayer ()
DECLARE SUB setLevelAppearance ()
DECLARE SUB initializeMates ()
DECLARE SUB initializeData ()
DECLARE FUNCTION checkBumps! (x AS INTEGER, y AS INTEGER, xvar AS INTEGER, yvar AS INTEGER)
DECLARE SUB generatePC ()
'Constants
CONST false = 0
CONST true = 1
' Behaviors
CONST BEHNONE = 0
CONST BEHWANDER = 1

'Treasures
CONST TRENONE = 0

'structures:
TYPE creature
        x AS INTEGER
        y AS INTEGER
        raceID AS INTEGER
        health AS INTEGER
        status AS INTEGER
        equipedItem AS INTEGER
        actionBar AS INTEGER
END TYPE

TYPE player
        playerName AS STRING * 12
        x AS INTEGER
        y AS INTEGER
        health AS INTEGER
        maxHP AS INTEGER
        status AS INTEGER
        speed AS INTEGER
        equipedWeapon AS INTEGER
        actionBar AS INTEGER
END TYPE

TYPE itemEquipment
        itemID AS INTEGER
        quantity AS INTEGER
END TYPE

TYPE itemMap
        x AS INTEGER
        y AS INTEGER
        itemID AS INTEGER
        quantity AS INTEGER
END TYPE

TYPE creatureDataT
        appearance AS STRING * 1
        creatureName AS STRING * 12
        maxHP AS INTEGER
        speed AS INTEGER
        behavior AS INTEGER
        treasureType AS INTEGER
END TYPE

'globals:
COMMON SHARED PC AS player
COMMON SHARED cNumber
COMMON SHARED iNumber
COMMON SHARED peNumber
COMMON SHARED levelNum
COMMON SHARED FINISHED

REDIM SHARED level(60, 20) AS STRING * 1
REDIM SHARED levelAppearance(20) AS STRING * 60

REDIM SHARED itemData(10) AS STRING * 12
REDIM SHARED creatureData(5) AS creatureDataT
cNumber = 0
REDIM SHARED creatures(cNumber) AS creature
iNumber = 0
REDIM SHARED items(iNumber) AS itemMap
peNumber = 0
REDIM SHARED playerEquipment(peNumber) AS itemEquipment
levelNum = 0
FINISHED = 0

DIM SHARED turns AS INTEGER
'init
RANDOMIZE TIMER
CLS
initializeData

generatePC
generateLevel (0)
intro

'main game loop
update
DO
        timeStep
        IF PC.actionBar >= 0 THEN
                update
                movePlayer
                update
        END IF
        FOR i = 0 TO cNumber - 1
                IF creatures(i).actionBar >= 0 THEN
                        moveCreature (i)
                END IF
        NEXT i
        turns = turns + 1
LOOP UNTIL FINISHED = 1

END

BUILDINGENTRANCEDATA:
DATA "          ########################################          "
DATA "   ########......................................########   "
DATA " ###....................................................### "
DATA "##........................................................##"
DATA "#..........................................................#"
DATA "#..........................................................#"
DATA "#..........................................................#"
DATA "#..........................................................#"
DATA "#..........................................................#"
DATA "#..........................................................#"
DATA "#..........................................................#"
DATA "#..........................................................#"
DATA "#..........................................................#"
DATA "#..........................................................#"
DATA "#..........................................................#"
DATA "#..........................................................#"
DATA "##........................................................##"
DATA " ###....................................................### "
DATA "   ########......................................########   "
DATA "          #################====###################          "

ItemDataLoad:
DATA "Eraser", "Stapler", "Diskette", "Ruler", "Keyboard"
DATA "Mouse", "Coofee cup", "Glue", "Wire", "Pen"

creatureDataLoad:
DATA "s", "Secretary", 20, 2, 1, 0
DATA "j", "Janitor", 30, 5, 1, 0
DATA "c", "C++ Progger", 35, 8, 1, 0
DATA "q", "QB Progger", 35, 8, 1, 0
DATA "j", "Java Progger", 35, 10, 1, 0

FUNCTION canWalkTo (x AS INTEGER, y AS INTEGER)

IF level(x, y) = "#" OR level(x, y) = "=" THEN
   canWalkTo = false
ELSE
   canWalkTo = true
END IF

END FUNCTION

SUB generateLevel (levelIndex AS INTEGER)

SELECT CASE levelIndex
  CASE -1:
        FOR y = 0 TO 19
          FOR x = 0 TO 59
            level(x, y) = "."
          NEXT x
        NEXT y
        FOR y = 0 TO 19
          level(0, y) = "#"
          level(59, y) = "#"
        NEXT y

        FOR x = 0 TO 59
          level(x, 0) = "#"
          level(x, 19) = "#"
        NEXT x
        initializeMates
  CASE 0:
        RESTORE BUILDINGENTRANCEDATA
        FOR y = 0 TO 19
          READ dataLine$
          FOR x = 0 TO 59
            level(x, y) = MID$(dataLine$, x + 1, 1)
          NEXT x
        NEXT y
        initializeMates
END SELECT
setLevelAppearance

END SUB

SUB generatePC
        INPUT "What is your name? ", PC.playerName
        PRINT "Your stats are chosen automatically."
        SLEEP 0
        PC.x = 5
        PC.y = 5
END SUB

SUB initializeData

RESTORE ItemDataLoad
FOR i = 0 TO 9
    READ itemData(i)
NEXT i

RESTORE creatureDataLoad
FOR i = 0 TO 4
   READ creatureData(i).appearance
   READ creatureData(i).creatureName
   READ creatureData(i).maxHP
   READ creatureData(i).speed
   READ creatureData(i).behavior
   READ creatureData(i).treasureType
NEXT i
END SUB

SUB initializeMates

cNumber = 3
REDIM creatures(cNumber) AS creature
FOR i = 0 TO cNumber - 1
  creatures(i).x = 5
  creatures(i).y = 5
  race = INT(RND * 3)
  creatures(i).raceID = race
  creatures(i).health = creatureData(race).maxHP

NEXT i

END SUB

SUB intro
PRINT "This is an intro uu uu"

END SUB

SUB moveCreature (index AS INTEGER)

SELECT CASE creatureData(creatures(index).raceID).behavior
CASE BEHNONE
        creatures(index).actionBar = -(101 - creatureData(creatures(index).raceID).speed)
CASE BEHWANDER
  xvar = 1 - INT(RND * 3)
  yvar = 1 - INT(RND * 3)
  IF canWalkTo(creatures(index).x + xvar, creatures(index).y + yvar) THEN
        creatures(index).y = creatures(index).y + yvar
        creatures(index).x = creatures(index).x + xvar
        creatures(index).actionBar = -(101 - creatureData(creatures(index).raceID).speed)
   END IF
   
END SELECT

END SUB

SUB movePlayer
'LOCATE 20, 1: PRINT "Player turn " + STR$(turns)
WHILE pressed$ = ""
pressed$ = INKEY$
WEND
SELECT CASE pressed$
  CASE "7"
    yvar = -1
    xvar = -1
  CASE "8"
    yvar = -1
  CASE "9"
    yvar = -1
    xvar = 1
  CASE "4"
    xvar = -1
  CASE "6"
    xvar = 1
  CASE "1"
    xvar = -1
    yvar = 1
  CASE "2"
    yvar = 1
  CASE "3"
    yvar = 1
    xvar = 1
END SELECT
IF canWalkTo(PC.x + xvar, PC.y + yvar) THEN
        PC.x = PC.x + xvar
        PC.y = PC.y + yvar
        PC.actionBar = -20
END IF
END SUB

SUB setLevelAppearance
FOR y = 0 TO 19
  FOR x = 0 TO 59
     acum$ = acum$ + level(x, y)
  NEXT x
  levelAppearance(y) = acum$
  acum$ = ""
NEXT y

END SUB

SUB showMap
'FOR x = 1 TO 60
'  FOR y = 1 TO 20
'        LOCATE y, x: PRINT "."
'  NEXT y
'NEXT x

FOR y = 0 TO 19
        LOCATE y + 1, 1: PRINT levelAppearance(y)
NEXT y

FOR i = 0 TO cNumber - 1
  LOCATE creatures(i).y + 1, creatures(i).x + 1
  PRINT creatureData(creatures(i).raceID).appearance
NEXT i


END SUB

SUB showPlayer
LOCATE PC.y + 1, PC.x + 1: PRINT "@"
END SUB

SUB showStatus
LOCATE 22, 1: PRINT RTRIM$(PC.playerName) + " the officer"

END SUB

SUB timeStep
FOR i = 0 TO cNumber - 1
        creatures(i).actionBar = creatures(i).actionBar + 1
NEXT i
PC.actionBar = PC.actionBar + 1
END SUB

SUB update
        showMap
        showStatus
        showPlayer
END SUB

