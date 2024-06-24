// priority: 0

// Visit the wiki for more info - https://kubejs.com/

console.info('Hello, World! (Loaded server scripts)')

ServerEvents.recipes(event => {




event.remove({ output: 'rats:rat_upgrade_enchanter' })
event.remove({ output: 'rats:rat_upgrade_disenchanter' })
event.remove({ output: 'rats:rat_upgrade_breeder' })
event.remove({ output: 'rats:rat_upgrade_fisherman' })
event.remove({ output: 'rats:rat_upgrade_lumberjack' })
event.remove({ output: 'rats:rat_upgrade_farmer' })
event.remove({ output: 'rats:rat_upgrade_quarry' })
event.remove({ output: 'rats:rat_upgrade_shears' })
event.remove({ output: 'rats:rat_upgrade_crafting' })


event.remove({ output: 'rats:rat_upgrade_chef' })
event.recipes.create.mechanical_crafting('rats:rat_upgrade_chef', [
    ' CUC ',
    'CRTRC',
    'USRKU',
    'CRPRC',
    ' CUC ',
    ], {
    C: 'rats:block_of_cheese',
    U: 'sophisticatedbackpacks:feeding_upgrade',
    R: 'rats:rat_upgrade_basic',
    T: 'rats:chef_toque',
    K: 'farmersdelight:iron_knife',
    P: 'farmersdelight:cooking_pot',
    S: 'farmersdelight:skillet'
    })


event.remove({ output: 'rats:rat_upgrade_basic' })
event.recipes.create.mechanical_crafting('rats:rat_upgrade_basic', [
    'CCC',
    'CDC',
    'CCC'
    ], {
    C: 'rats:block_of_cheese',
    D: 'minecraft:diamond',
    })


event.remove({ output: 'alexscaves:uranium_rod' })
event.recipes.create.mechanical_crafting('alexscaves:uranium_rod', [
    'CCC',
    'TUT',
    'TUT',
    'CCC'
    ], {
    C: 'createdeco:industrial_iron_sheet',
    T: 'minecraft:tinted_glass',
    U: 'alexscaves:block_of_uranium'
    })

 event.remove({ output: 'alexscaves:fissile_core' })
event.recipes.create.mechanical_crafting('alexscaves:fissile_core', [
    ' CCC ',
    'CSTSC',
    'CTUTC',
    'CSTSC',
    ' CCC '
    ], {
    C: 'createdeco:industrial_iron_ingot',
    T: 'alexscaves:uranium_rod',
    U: 'alexscaves:block_of_uranium',
    S:'create:sturdy_sheet'
    })


event.remove({id: 'create:industrial_iron_block_from_ingots_iron_stonecutting'})

event.remove({ output: 'alexscaves:nuclear_bomb' })
event.recipes.create.mechanical_crafting('alexscaves:nuclear_bomb', [
    ' BCB ',
    'BCFCB',
    'CDZTC',
    'BCFCB',
    ' BCB '
    ], {
    C: 'createdeco:industrial_iron_ingot',
    T: 'create:precision_mechanism',
    D: 'alexscaves:remote_detonator',
    Z:'createdeco:zinc_sheet',
    F:'alexscaves:fissile_core',
    B:'create:industrial_iron_block'
    })



event.remove({ output: 'alexscaves:remote_detonator' })
event.shaped('alexscaves:remote_detonator', [
    ' A ',
    'ARA',
    ' A '
], {
    R: 'create:redstone_link',
    A: 'createdeco:industrial_iron_sheet'
})




event.remove({ output: 'alexscaves:charred_remnant' })
event.recipes.create.mechanical_crafting('alexscaves:charred_remnant', [
    ' T ',
    'TUT',
    'TTT'
    ], {
    T: 'createdeco:industrial_iron_ingot',
    U: 'alexscaves:uranium_rod'
    })



event.remove({ output: Item.of('apotheosis:ender_lead', '{Damage:0,entity_data:{}}') })
event.shapeless('apotheosis:ender_lead', [
    'waystones:warp_stone',
    'minecraft:lead',
    'minecraft:gold_ingot'
  ])

event.remove({ output: 'minecraft:ender_eye' })
event.recipes.create.mixing('minecraft:ender_eye', ['minecraft:ender_pearl','3x blaze_powder', Fluid.of('create_enchantment_industry:experience',5)]).heated()



event.recipes.create.mixing('apotheotic_additions:apotheotic_coin', ['6x create:brass_nugget', Fluid.of('create_enchantment_industry:experience',8)]).heated()





event.remove({ output: 'sophisticatedbackpacks:iron_backpack' })
event.shaped('sophisticatedbackpacks:iron_backpack', [
    'AAA',
    'ABA',
    'AAA'
], {
    B: 'sophisticatedbackpacks:copper_backpack',
    A: 'minecraft:iron_ingot'
})

event.remove({ output: 'sophisticatedbackpacks:diamond_backpack' })
event.shaped('sophisticatedbackpacks:diamond_backpack', [
    'AAA',
    'CBC',
    'AAA'
], {
    B: 'sophisticatedbackpacks:gold_backpack',
    A: 'minecraft:diamond',
    C: 'minecraft:diamond_block'
})


event.remove({ output: 'sophisticatedstorage:netherite_barrel' })
event.remove({ output: 'sophisticatedstorage:limited_netherite_barrel_1' })
event.remove({ output: 'sophisticatedstorage:limited_netherite_barrel_2' })
event.remove({ output: 'sophisticatedstorage:limited_netherite_barrel_3' })
event.remove({ output: 'sophisticatedstorage:limited_netherite_barrel_4' })

event.remove({ output: 'sophisticatedstorage:basic_to_netherite_tier_upgrade' })
event.remove({ output: 'sophisticatedstorage:copper_to_netherite_tier_upgrade' })
event.remove({ output: 'sophisticatedstorage:iron_to_netherite_tier_upgrade' })
event.remove({ output: 'sophisticatedstorage:gold_to_netherite_tier_upgrade' })
event.remove({ output: 'sophisticatedstorage:diamond_to_netherite_tier_upgrade' })


event.remove({ output: 'sophisticatedstorage:netherite_chest' })
event.remove({ output: 'sophisticatedstorage:netherite_shulker_box' })


event.remove({ output: 'monobank:monobank' })
event.shaped('monobank:monobank', [
    'BIB',
    'LRI',
    'BIB'
], {
    B: 'create:industrial_iron_block',
    I: 'createdeco:industrial_iron_sheet',
    L:'monobank:replacement_lock',
    R:'minecraft:barrel'
})
event.remove({ output: 'createarmory:barrel_part' })
event.shaped('createarmory:barrel_part', [
    'S ',
    'S ',
    '  '
], {
   S:'createdeco:industrial_iron_sheet'
})

event.shaped('createarmory:impact_nade', [
    'GS ',
    'IG ',
    '   '
], {
   I:'createdeco:industrial_iron_sheet',
   S:'minecraft:string',
   G:'minecraft:gunpowder'
})

event.shaped('createarmory:smoke_nade', [
    'AS ',
    'IG ',
    '   '
], {
   I:'createdeco:industrial_iron_sheet',
   S:'minecraft:string',
   G:'minecraft:gunpowder',
   A:'supplementaries:ash'
})


event.remove({id:'create:crushing/prismarine_crystals'})
event.recipes.create.crushing(['kubejs:prismarine_powder', Item.of('kubejs:prismarine_powder').withChance(0.25)], 'minecraft:prismarine_crystals')
event.recipes.create.mixing('alexscaves:sea_glass_shards', 'kubejs:prismarine_powder').superheated()

event.recipes.create.mechanical_crafting('alexscaves:enigmatic_engine', [
    ' BIB ',
    'BCTGB',
    'IVEVI',
    'BGPCB',
    ' BIB '
    ], {
    E: 'create_sa:heat_engine',
    C: 'create:cogwheel',
    G: 'create:large_cogwheel',
    V:'create:copper_valve_handle',
    I:'create:copper_sheet',
    B:'minecraft:copper_block',
    T:'create:electron_tube',
    P:'create:propeller'
    })
})




