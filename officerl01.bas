'   ---   ---===---   ---===###===---   ---===---   ---   '
' OfficeRL                                                '
' by Team @tRoCiouS                                       '
' 2005 - I hope :)                                         '
'   ---   ---===---   ---===###===---   ---===---   ---   '

DECLARE SUB DimEffect ()
DECLARE SUB Message (text AS STRING)
DECLARE FUNCTION canWalkTo! (x AS INTEGER, y AS INTEGER)
DECLARE SUB GenerateLevel (levelIndex AS INTEGER)
DECLARE SUB Intro ()
DECLARE SUB ShowMap ()
DECLARE SUB ShowStatus ()
DECLARE SUB TimeStep ()
DECLARE SUB MovePlayer ()
DECLARE SUB MoveCreature (index AS INTEGER)
DECLARE SUB Update ()
DECLARE SUB ShowPlayer ()
DECLARE SUB setLevelAppearance ()
DECLARE SUB InitializeMates ()
DECLARE SUB InitializeData ()
DECLARE FUNCTION checkBumps! (x AS INTEGER, y AS INTEGER, xvar AS INTEGER, yvar AS INTEGER)

DECLARE SUB GeneratePC ()
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

TYPE Player
        playerName AS STRING * 12
        x AS INTEGER
        y AS INTEGER
        'features:
        STR AS INTEGER 'strenght
        AGI AS INTEGER 'agility
        INL AS INTEGER 'inteligence, can't be INT
        health AS INTEGER
        maxHP AS INTEGER
        status AS INTEGER
        speed AS INTEGER
        equipedWeapon AS INTEGER
        actionBar AS INTEGER
        xp AS INTEGER
        level AS INTEGER
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
        STR AS INTEGER
        AGL AS INTEGER
        INL AS INTEGER
        maxHP AS INTEGER
        speed AS INTEGER
        behavior AS INTEGER
        treasureType AS INTEGER
END TYPE

'globals:
COMMON SHARED PC AS Player 'pc data
COMMON SHARED cNumber 'numer of creatures
COMMON SHARED iNumber 'number of items
COMMON SHARED peNumber
COMMON SHARED levelNum 'current level
COMMON SHARED FINISHED 'is game finished?
COMMON SHARED lastMsg$ 'for dimming effect
COMMON SHARED msgCounter 'for dimming effect
'dimming effect
'1 white message
'2 grey message
'3 dark grey message
'4 no message

REDIM SHARED level(60, 20) AS STRING * 1
REDIM SHARED levelAppearance(20) AS STRING * 60

REDIM SHARED itemData(10) AS STRING * 12
REDIM SHARED creatureData(6) AS creatureDataT
cNumber = 0
REDIM SHARED creatures(cNumber) AS creature
iNumber = 0
REDIM SHARED items(iNumber) AS itemMap
peNumber = 0
REDIM SHARED playerEquipment(peNumber) AS itemEquipment
levelNum = 0
FINISHED = 0
msgCounter = 5 'no dim

DIM SHARED turns AS INTEGER

'   ---   ---===---   ---===###===---   ---===---   ---   '

'init
RANDOMIZE TIMER
SCREEN 0
CLS
InitializeData

GeneratePC
GenerateLevel (0)
Intro

'   ---   ---===---   ---===###===---   ---===---   ---   '

'main game loop
'Update
DO
        TimeStep
        IF PC.actionBar >= 500 THEN
                turns = turns + 1
                Update
                MovePlayer
                Update
        END IF
        FOR i = 0 TO cNumber - 1
                IF creatures(i).actionBar >= 500 THEN
                        MoveCreature (i)
                END IF
        NEXT i
LOOP UNTIL FINISHED = 1

END

'   ---   ---===---   ---===###===---   ---===---   ---   '

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
'appearance, name, str, agl, int, behavior, treasure
DATA "s", "Secretary", 4, 4, 5, 1, 0
DATA "j", "Janitor", 5, 5, 5, 1, 0
DATA "C", "C++ Progger", 6, 6, 5, 1, 0
DATA "q", "QB Progger", 6, 6, 5, 1, 0
DATA "J", "Java Progger", 7, 7, 6, 1, 0
DATA "c", "Courier", 4, 7, 5, 1, 0
DATA "A", "Admin", 4, 3, 9, 1, 0

'DATA "s", "Secretary", 20, 2, 1, 0
'DATA "j", "Janitor", 30, 5, 1, 0
'DATA "c", "C++ Progger", 35, 8, 1, 0
'DATA "q", "QB Progger", 35, 8, 1, 0
'DATA "j", "Java Progger", 35, 10, 1, 0

FUNCTION canWalkTo (x AS INTEGER, y AS INTEGER)
IF level(x, y) = "#" OR level(x, y) = "=" THEN
   canWalkTo = false
ELSE
   canWalkTo = true
END IF
END FUNCTION

SUB DimEffect
        IF msgCounter < 5 THEN msgCounter = msgCounter + 1
        IF msgCounter = 2 THEN
                LOCATE 23
                COLOR 7
                PRINT lastMsg$
        ELSEIF msgCounter = 3 THEN
                LOCATE 23
                COLOR 8
                PRINT lastMsg$
        ELSEIF msgCounter = 4 THEN
                LOCATE 23
                COLOR 0
                PRINT lastMsg$
        END IF
END SUB

SUB GenerateLevel (levelIndex AS INTEGER)

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
        InitializeMates
  CASE 0:
        RESTORE BUILDINGENTRANCEDATA
        FOR y = 0 TO 19
          READ dataLine$
          FOR x = 0 TO 59
            level(x, y) = MID$(dataLine$, x + 1, 1)
          NEXT x
        NEXT y
END SELECT
setLevelAppearance
END SUB

SUB GeneratePC
        INPUT "What is your name? ", PC.playerName
        PC.STR = 5
        PC.AGI = 5
        PC.INL = 5

        PC.maxHP = 5 + PC.STR / 2
        PC.health = PC.maxHP
        PC.speed = 90 + 2 * PC.AGI
        PC.status = 0
        equipedWeapon = 0
        actionBar = 0

        PC.x = 5
        PC.y = 5
END SUB

SUB InitializeData

RESTORE ItemDataLoad
FOR i = 0 TO 9
    READ itemData(i)
NEXT i

RESTORE creatureDataLoad
FOR i = 0 TO 6
   READ creatureData(i).appearance
   READ creatureData(i).creatureName
   READ creatureData(i).STR
   READ creatureData(i).AGL
   READ creatureData(i).INL
   'READ creatureData(i).maxHP
   'READ creatureData(i).speed
   creatureData(i).maxHP = 4 + creatureData(i).STR / 2
   creatureData(i).speed = 90 + creatureData(i).AGL * 2
   READ creatureData(i).behavior
   READ creatureData(i).treasureType
NEXT i
END SUB

SUB InitializeMates
cNumber = 3
REDIM creatures(cNumber) AS creature
FOR i = 0 TO cNumber - 1
  creatures(i).x = 5
  creatures(i).y = 5
  race = INT(RND * 5) 'why additional variable here?
  creatures(i).raceID = race
  creatures(i).health = creatureData(race).maxHP
NEXT i
END SUB

SUB Intro
PRINT "This is an intro uu uu"

END SUB

SUB Message (text AS STRING)
IF msgCounter < 4 THEN
        LOCATE 23
        COLOR 0
        PRINT lastMsg
END IF
lastMsg$ = text
COLOR 15
LOCATE 23
PRINT text
msgCounter = 1
END SUB

SUB MoveCreature (index AS INTEGER)

SELECT CASE creatureData(creatures(index).raceID).behavior
CASE BEHNONE
        'creatures(index).actionBar = -(101 - creatureData(creatures(index).raceID).speed)
CASE BEHWANDER
  xvar = 1 - INT(RND * 3)
  yvar = 1 - INT(RND * 3)
  IF canWalkTo(creatures(index).x + xvar, creatures(index).y + yvar) THEN
        creatures(index).y = creatures(index).y + yvar
        creatures(index).x = creatures(index).x + xvar
        creatures(index).actionBar = -(101 - creatureData(creatures(index).raceID).speed)
  END IF
creatures(index).actionBar = creatures(index).actionBar - 500
END SELECT
END SUB

SUB MovePlayer
'Message ("Player turn " + STR$(turns))
DimEffect
moved = false
DO
        DO WHILE pressed$ = ""
                pressed$ = INKEY$
        LOOP
        IF (ASC(pressed$) >= 48) AND (ASC(pressed$) <= 57) THEN
                IF pressed$ = "7" THEN
                        xvar = -1
                        yvar = -1
                ELSEIF pressed$ = "3" THEN
                        xvar = 1
                        yvar = 1
                ELSEIF pressed$ = "1" THEN
                        xvar = -1
                        yvar = 1
                ELSEIF pressed$ = "9" THEN
                        xvar = 1
                        yvar = -1
                ELSEIF pressed$ = "8" THEN
                        yvar = -1
                ELSEIF pressed$ = "2" THEN
                        yvar = 1
                ELSEIF pressed$ = "4" THEN
                        xvar = -1
                ELSEIF pressed$ = "6" THEN
                        xvar = 1
                END IF
                IF canWalkTo(PC.x + xvar, PC.y + yvar) THEN
                        PC.x = PC.x + xvar
                        PC.y = PC.y + yvar
                        moved = true
                END IF
        ELSEIF pressed$ = "Q" THEN
                FINISHED = true
                moved = true 'let that monster hit player for the last  time...
        ELSEIF pressed$ = "?" THEN
                Message ("Online help has been disabled by the servers...")
        ELSE
                Message ("Unknown key.")
        END IF
        pressed$ = ""
LOOP UNTIL moved = true
PC.actionBar = PC.actionBar - 500
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

SUB ShowMap
FOR y = 0 TO 19
        LOCATE y + 1, 1: PRINT levelAppearance(y)
NEXT y
FOR i = 0 TO cNumber - 1
        LOCATE creatures(i).y + 1, creatures(i).x + 1
        PRINT creatureData(creatures(i).raceID).appearance
NEXT i
END SUB

SUB ShowPlayer
LOCATE PC.y + 1, PC.x + 1: PRINT "@"
END SUB

SUB ShowStatus
LOCATE 22
PRINT PC.playerName + " the officer | XP:" + STR$(PC.xp) + "/" + STR$(PC.level) + " | HP:" + STR$(PC.health) + "/" + STR$(PC.maxHP) + " | T:" + STR$(turns)
END SUB

SUB TimeStep
FOR i = 0 TO cNumber - 1
        creatures(i).actionBar = creatures(i).actionBar + creatureData(creatures(i).raceID).speed
NEXT i
PC.actionBar = PC.actionBar + PC.speed
END SUB

SUB Update
        COLOR 7
        ShowMap
        ShowStatus
        ShowPlayer
        'dimming:
END SUB

