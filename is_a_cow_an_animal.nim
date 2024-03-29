from strutils import spaces

type
    FoodMismatch* = object of Exception
    Dead* = object of Exception
    EatenAlready* = object of Exception

    FoodType* = enum
        Meat, Grass, Carrot

    Food* = ref object of RootObj
        energy*:   uint32
        foodType*: FoodType
        eaten*:    bool

    Animal* = ref object of RootObj
        energy*: uint32
        name*:   string
        alive*:  bool
        canEat*: seq[FoodType]


method eat*(this: Animal, food: Food): void {.base.} =
    if not this.alive:
        raise newException(Dead, "Animal is dead")
    # Fun fact: case-sensetive checking only applies
    # to first letter, i.e f.foodtype == f.foodTYPE
    if not (food.foodtype in this.canEat):
        raise newException(FoodMismatch, "Mismatched food")
    if food.foodtype == Meat and food.eaten == true:
        raise newException(EatenAlready, "This meat is being eaten twice")
    if food.foodtype == Meat:
        food.eaten = true
    this.energy += food.energy
    


method slaughter*(this: Animal): Food {.base.} =
    if not this.alive:
        raise newException(Dead, "Animal is already dead")
    this.alive  = false
    result      = Food(energy: this.energy, foodType: Meat, eaten: false)
    this.energy = 0



let
    grass  = Food(energy: 5,  foodType: Grass,  eaten: false)
    carrot = Food(energy: 10, foodType: Carrot, eaten: false)

let
    rabbit = Animal(energy: 100,  name: "Rabbit", alive: true, canEat: @[Carrot])
    cow    = Animal(energy: 1000, name: "Cow",    alive: true, canEat: @[Grass])
    human  = Animal(energy: 300,  name: "Hooman", alive: true, canEat: @[Carrot, Meat])
    ahuman = Animal(energy: 350,  name: "Another Hooman", alive: true, canEat: @[Carrot, Meat])

for i in [rabbit, cow, human, ahuman]:
    echo i.name, spaces(15-i.name.len), "-> ", i.energy
echo ""

rabbit.eat(carrot)
cow.eat(grass)

let
    deadRabbit = rabbit.slaughter()
    beef = cow.slaughter()

human.eat(carrot)
human.eat(carrot)
human.eat(beef)

let
    deadHuman = ahuman.slaughter()

human.eat(deadHuman)

for i in [rabbit, cow, human, ahuman]:
    echo i.name, spaces(15-i.name.len), "-> ", i.energy, (if not i.alive: " [Dead]" else: "")

assert(human.energy == 1675, "No, it's " & $human.energy)

