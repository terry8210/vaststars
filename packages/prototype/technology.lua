local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

  --task = {"stat_production", 0, "铁矿石"},
  --task = {"stat_consumption", 0, "铁矿石"},
  --task = {"select_entity", 0, "组装机"},
  --task = {"select_chest", 0, "指挥中心", "铁丝"},
  --task = {"power_generator", 0},
  --time是指1个count所需的时间

prototype "地质研究" {
    desc = "对火星地质结构进行标本采集和研究",
    type = { "tech" },
    icon = "textures/science/tech-research.texture",
    effects = {
      unlock_recipe = {"地质科技包1"},
    },
    ingredients = {
    },
    count = 5,
    time = "3s",
    sign_desc = {
      { desc = "该科技是火星探索的前沿科技，它可以引导更多的科技研究", icon = "textures/science/important.texture"},
    },
    sign_icon = "textures/science/tech-important.texture",
}

prototype "挖掘铁矿石" {
  desc = "挖掘足够的铁矿石可以开始进行锻造",
  icon = "textures/construct/industry.texture",
  type = { "tech", "task" },
  task = {"stat_production", 0, "铁矿石"},
  -- task = {"select_chest", 0, "指挥中心", "铁矿石"},
  prerequisites = {"地质研究"},
  count = 10,
  tips_pic = {
    "textures/task_tips_pic/task_click_build.texture",
    "textures/task_tips_pic/task_produce_ore1.texture",
    "textures/task_tips_pic/task_produce_ore2.texture",
    "textures/task_tips_pic/start_construct.texture",
    "textures/task_tips_pic/task_produce_ore3.texture",
  },
  sign_desc = {
    { desc = "放置采矿机挖掘10个铁矿石", icon = "textures/construct/industry.texture"},
  },
}

prototype "生产地质科技包" {
  desc = "生产科技包用于科技研究",
  icon = "textures/construct/assembler.texture",
  type = { "tech", "task" },
  task = {"stat_production", 0, "地质科技包"},
  prerequisites = {"挖掘铁矿石"},
  count = 3,
  tips_pic = {
    "textures/task_tips_pic/task_click_build.texture",
    "textures/task_tips_pic/task_produce_geopack1.texture",
    "textures/task_tips_pic/task_produce_geopack2.texture",
    "textures/task_tips_pic/start_construct.texture",
    "textures/task_tips_pic/task_produce_geopack3.texture",
    "textures/task_tips_pic/task_produce_geopack4.texture",
    "textures/task_tips_pic/task_produce_geopack5.texture",
    "textures/task_tips_pic/task_produce_geopack6.texture",
  },
  sign_desc = {
    { desc = "使用组装机生产3个地质科技包", icon = "textures/construct/iron-ingot.texture"},
  },
}

prototype "铁矿熔炼" {
  desc = "掌握熔炼铁矿石冶炼成铁板的工艺",
  type = { "tech" },
  icon = "textures/science/tech-metal.texture",
  effects = {
    unlock_recipe = {"铁板1"},
  },
  prerequisites = {"生产地质科技包"},
  ingredients = {
      {"地质科技包", 1},
  },
  count = 4,
  time = "3s"
}

prototype "生产铁板" {
  desc = "铁板可以打造坚固器材，对于基地建设多多益善",
  icon = "textures/construct/iron-ingot.texture",
  type = { "tech", "task" },
  task = {"stat_production", 0, "铁板"},
  prerequisites = {"铁矿熔炼"},
  count = 8,
  tips_pic = {
    "textures/task_tips_pic/task_produce_ironplate1.texture",
    "textures/task_tips_pic/task_produce_ironplate2.texture",
    "textures/task_tips_pic/task_produce_ironplate3.texture",
    "textures/task_tips_pic/task_produce_ironplate4.texture",
    "textures/task_tips_pic/task_produce_ironplate5.texture",
  },
  sign_desc = {
    { desc = "使用熔炼炉生产8个铁板", icon = "textures/construct/iron-ingot.texture"},
  },
}

prototype "石头处理1" {
  desc = "获得火星岩石加工成石砖的工艺",
  type = { "tech" },
  icon = "textures/construct/stone-brick.texture",
  effects = {
    unlock_recipe = {"石砖"},
  },
  prerequisites = {"生产铁板"},
  ingredients = {
      {"地质科技包", 1},
  },
  count = 4,
  time = "1s"
}

prototype "生产石砖" {
  desc = "石砖可以打造基础建筑，对于基地建设多多益善",
  icon = "textures/construct/stone-brick.texture",
  type = { "tech", "task" },
  task = {"stat_production", 0, "石砖"},
  prerequisites = {"石头处理1"},
  count = 5,
  tips_pic = {
    "textures/task_tips_pic/task_produce_stonebrick.texture",
  },
  sign_desc = {
    { desc = "使用组装机生产5个石砖", icon = "textures/construct/stone-brick.texture"},
  },
}

prototype "气候研究" {
  desc = "对火星大气成分进行标本采集和研究",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"破损空气过滤器","破损地下水挖掘机","气候科技包"},
  },
  prerequisites = {"生产石砖"},
  ingredients = {
      {"地质科技包", 1},
  },
  sign_desc = {
    { desc = "该科技是火星探索的前沿科技，它可以引导更多的科技研究", icon = "textures/science/important.texture"},
  },
  sign_icon = "textures/science/tech-important.texture",
  count = 6,
  time = "1.5s"
}

-- ---新增地下卤水配方的对应科技---
-- prototype "地下卤水提取铁矿" {
--   type = { "tech" },
--   icon = "textures/science/tech-metal.texture",
--   effects = {
--     unlock_recipe = {"地下卤水分离铁"},
--   },
--   prerequisites = {"地质研究"},
--   ingredients = {
--       {"地质科技包", 3},
--   },
--   count = 4,
--   time = "1s"
-- }

-- ---新增地下卤水配方的对应科技---
-- prototype "地下卤水提取石矿" {
--   type = { "tech" },
--   icon = "textures/science/tech-metal.texture",
--   effects = {
--     unlock_recipe = {"地下卤水分离石头"},
--   },
--   prerequisites = {"铁矿收集"},
--   ingredients = {
--       {"地质科技包", 3},
--   },
--   count = 4,
--   time = "1s"
-- }

prototype "维修破损空气过滤器" {
  desc = "将破损的机器修复会大大节省建设时间和资源",
  icon = "textures/construct/modify.texture",
  type = { "tech", "task" },
  task = {"stat_consumption", 0, "破损空气过滤器"},
  prerequisites = {"气候研究"},
  count = 1,
  tips_pic = {
    "textures/task_tips_pic/task_repair_airfilter.texture",
  },
  sign_desc = {
    { desc = "使用组装机维修1个破损空气过滤器", icon = "textures/construct/modify.texture"},
  },
}

prototype "维修破损地下水挖掘机" {
  desc = "将破损的机器修复会大大节省建设时间和资源",
  icon = "textures/construct/modify.texture",
  type = { "tech", "task" },
  task = {"stat_consumption", 0, "破损地下水挖掘机"},
  prerequisites = {"气候研究"},
  count = 1,
  tips_pic = {
    "textures/task_tips_pic/task_repair_digger.texture",
  },
  sign_desc = {
    { desc = "使用组装机维修1个破损地下水挖掘机", icon = "textures/construct/modify.texture"},
  },
}

prototype "生产气候科技包" {
  desc = "生产科技包用于科技研究",
  icon = "textures/construct/assembler.texture",
  type = { "tech", "task" },
  task = {"stat_production", 0, "气候科技包"},
  prerequisites = {"维修破损空气过滤器","维修破损地下水挖掘机"},
  count = 2,
  tips_pic = {
    "textures/task_tips_pic/task_produce_climatepack1.texture",
    "textures/task_tips_pic/task_produce_climatepack2.texture",
    "textures/task_tips_pic/task_produce_climatepack3.texture",
    "textures/task_tips_pic/task_produce_climatepack4.texture",
    "textures/task_tips_pic/task_produce_climatepack5.texture",
  },
  sign_desc = {
    { desc = "使用水电站生产2个气候科技包", icon = "textures/construct/assembler.texture"},
  },
}

prototype "管道系统1" {
  desc = "研究装载和运输液体或气体的管道",
  type = { "tech" },
  icon = "textures/science/tech-chemical.texture",
  effects = {
    unlock_recipe = {"管道1","管道2","液罐1"},
  },
  prerequisites = {"生产气候科技包"},
  ingredients = {
      {"地质科技包", 1},
      {"气候科技包", 1},
  },
  count = 4,
  time = "1s"
}

prototype "生产管道" {
  desc = "管道可以承载液体和气体，将需要相同气液的机器彼此联通起来",
  icon = "textures/construct/pipe.texture",
  type = { "tech", "task" },
  task = {"stat_production", 0, "管道1-I型"},
  prerequisites = {"管道系统1"},
  count = 10,
  tips_pic = {
    "textures/task_tips_pic/task_produce_pipe1.texture",
  },
  sign_desc = {
    { desc = "使用组装机生产10个管道", icon = "textures/construct/assembler.texture"},
  },
}

prototype "水利研究" {
  desc = "对火星地层下的水源进行开采",
  type = { "tech" },
  icon = "textures/science/tech-chemical.texture",
  effects = {
    unlock_recipe = {"破损水电站"},
  },
  prerequisites = {"生产管道"},
  ingredients = {
      {"地质科技包", 1},
      {"气候科技包", 1},
  },
  count = 4,
  time = "1s"
}


prototype "电解" {
  desc = "科技的描述",
  type = { "tech" },
  icon = "textures/science/tech-liquid.texture",
  effects = {
    unlock_recipe = {"地下卤水电解","破损电解厂"},
  },
  prerequisites = {"水利研究"},
  ingredients = {
      {"气候科技包", 1},
  },
  count = 5,
  time = "2s"
}

prototype "空气分离" {
  desc = "获得火星大气分离出纯净气体的工艺",
  type = { "tech" },
  icon = "textures/science/tech-liquid.texture",
  effects = {
    unlock_recipe = {"空气分离1"},
  },
  prerequisites = {"水利研究"},
  ingredients = {
      {"气候科技包", 1},
  },
  count = 4,
  time = "1.5s"
}

prototype "收集空气" {
  desc = "采集火星上的空气",
  type = { "tech", "task" },
  icon = "textures/science/tech-liquid.texture",
  task = {"stat_production", 1, "空气"},
  prerequisites = {"空气分离"},
  count = 8000,
  tips_pic = {
    "textures/task_tips_pic/task_produce_air1.texture",
    "textures/task_tips_pic/task_produce_air2.texture",
  },
  sign_desc = {
    { desc = "用空气过滤器生产80000单位空气", icon = "textures/science/tech-liquid.texture",},
  },
}

prototype "铁加工1" {
  desc = "获得铁板加工铁齿轮的工艺",
  type = { "tech" },
  icon = "textures/science/tech-metal.texture",
  effects = {
    unlock_recipe = {"铁齿轮","破损组装机"},
  },
  prerequisites = {"生产管道"},
  ingredients = {
      {"地质科技包", 1},
  },
  count = 6,
  time = "2s"
}

prototype "维修破损组装机" {
  desc = "将破损的机器修复会大大节省建设时间和资源",
  icon = "textures/construct/modify.texture",
  type = { "tech", "task" },
  task = {"stat_consumption", 0, "破损组装机"},
  prerequisites = {"铁加工1"},
  count = 3,
  tips_pic = {
    "textures/task_tips_pic/task_repair_assembler.texture",
  },
  sign_desc = {
    { desc = "使用组装机维修3个破损组装机", icon = "textures/construct/modify.texture"},
  },
}

prototype "石头处理2" {
  desc = "对火星岩石成分的研究",
  type = { "tech" },
  icon = "textures/science/tech-metal.texture",
  effects = {
    unlock_recipe = {"破损太阳能板","破损蓄电池"},
  },
  prerequisites = {"维修破损组装机","电解"},
  ingredients = {
      {"地质科技包", 1},
  },
  count = 8,
  time = "2s"
}

prototype "放置太阳能板" {
  desc = "放置太阳能板将光热转换成电能",
  icon = "textures/construct/construct.texture",
  type = { "tech", "task" },
  task = {"select_entity", 0, "太阳能板I"},
  prerequisites = {"石头处理2"},
  count = 8,
  tips_pic = {
    "textures/task_tips_pic/task_place_solarpanel.texture",
  },
  sign_desc = {
    { desc = "放置8个太阳能板", icon = "textures/construct/assembler.texture"},
  },
}

prototype "基地生产1" {
  desc = "提高指挥中心的生产效率",
  type = { "tech" },
  icon = "textures/science/tech-logistics.texture",
  effects = {
    modifier = {["headquarter-mining-speed"] = 0.1},
  },
  prerequisites = {"维修破损组装机"},
  ingredients = {
      {"地质科技包", 1},
  },
  count = 8,
  time = "1s",
  sign_desc = {
    { desc = "该科技可以持续地提高某项能力", icon = "textures/science/recycle.texture"},
  },
  sign_icon = "textures/science/tech-cycle.texture",
}

prototype "储存1" {
  desc = "研究更便捷的存储方式",
  type = { "tech" },
  icon = "textures/construct/chest.texture",
  effects = {
    unlock_recipe = {"小型铁制箱子"},
  },
  prerequisites = {"维修破损组装机"},
  ingredients = {
      {"地质科技包", 1},
      {"气候科技包", 1},
  },
  count = 6,
  time = "2s"
}

prototype "生产铁制箱子" {
  desc = "生产小型铁制箱子用于存储基地的资源",
  icon = "textures/construct/assembler.texture",
  type = { "tech", "task" },
  task = {"stat_production", 0, "小型铁制箱子"},
  prerequisites = {"储存1","基地生产1"},
  count = 3,
  tips_pic = {
    "textures/task_tips_pic/task_produce_chest.texture",
  },
  sign_desc = {
    { desc = "使用组装机生产3个小型铁制箱子", icon = "textures/construct/assembler.texture"},
  },
}

prototype "碳处理1" {
  desc = "含碳气体化合成其他物质的工艺",
  type = { "tech" },
  icon = "textures/science/tech-chemical.texture",
  effects = {
    unlock_recipe = {"二氧化碳转甲烷","破损化工厂"},
  },
  prerequisites = {"电解","空气分离","放置太阳能板"},
  ingredients = {
      {"气候科技包", 1},
  },
  count = 4,
  time = "2s"
}

prototype "生产氢气" {
  desc = "生产工业气体氢气",
  icon = "textures/science/tech-liquid.texture",
  type = { "tech", "task" },
  task = {"stat_production", 0, "氢气"},
  prerequisites = {"碳处理1"},
  count = 500,
  tips_pic = {
    "textures/task_tips_pic/task_produce_h21.texture",
    "textures/task_tips_pic/task_produce_h22.texture",
  },
  sign_desc = {
    { desc = "电解厂电解卤水生产500个单位氢气", icon = "textures/fluid/gas.texture"},
  },
}

prototype "生产二氧化碳" {
  desc = "生产工业气体二氧化碳",
  icon = "textures/science/tech-liquid.texture",
  type = { "tech", "task" },
  task = {"stat_production", 0, "二氧化碳"},
  prerequisites = {"碳处理1"},
  count = 500,
  tips_pic = {
    "textures/task_tips_pic/task_produce_co21.texture",
    "textures/task_tips_pic/task_produce_co22.texture",
  },
  sign_desc = {
    { desc = "蒸馏厂分离空气生产500个单位二氧化碳", icon = "textures/fluid/gas.texture"},
  },
}

prototype "碳处理2" {
  desc = "含碳气体化合成其他物质的工艺",
  type = { "tech" },
  icon = "textures/science/tech-chemical.texture",
  effects = {
    unlock_recipe = {"甲烷转乙烯"},
    -- unlock_recipe = {"二氧化碳转一氧化碳","一氧化碳转石墨"},
  },
  prerequisites = {"生产氢气","生产二氧化碳"},
  ingredients = {
      {"气候科技包", 1},
  },
  count = 8,
  time = "2s"
}

prototype "管道系统2" {
  desc = "研究装载和运输液体或气体的管道",
  type = { "tech" },
  icon = "textures/science/tech-chemical.texture",
  effects = {
    unlock_recipe = {"破损化工厂","地下管1"},
  },
  prerequisites = {"收集空气","放置太阳能板"},
  ingredients = {
      {"地质科技包", 1},
      {"气候科技包", 1},
  },
  count = 5,
  time = "2s"
}

prototype "有机化学" {
  desc = "研究碳化合物组成、结构和制备方法",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"塑料1"},
  },
  prerequisites = {"生产甲烷"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
  },
  count = 6,
  time = "10s"
}

prototype "排放" {
  desc = "研究气体和液体的排放工艺",
  type = { "tech" },
  icon = "textures/science/tech-liquid.texture",
  effects = {
    unlock_recipe = {"烟囱1","排水口1"},
  },
  prerequisites = {"管道系统2"},
  ingredients = {
    {"气候科技包", 1},
  },
  count = 8,
  time = "2s"
}

prototype "冶金学" {
  desc = "研究工业高温熔炼的装置",
  type = { "tech" },
  icon = "textures/science/tech-metal.texture",
  effects = {
    unlock_recipe = {"熔炼炉1"},
  },
  prerequisites = {"放置太阳能板","生产铁制箱子"},
  ingredients = {
    {"地质科技包", 1},
  },
  count = 5,
  time = "4s"
}

prototype "基地生产2" {
  desc = "提高指挥中心的生产效率",
  type = { "tech" },
  icon = "textures/science/tech-manufacture.texture",
  effects = {
    modifier = {["headquarter-craft-speed"] = 0.2},
  },
  prerequisites = {"冶金学"},
  ingredients = {
      {"地质科技包", 1},
  },
  count = 10,
  time = "2s",
  sign_desc = {
    { desc = "该科技可以持续地提高某项能力", icon = "textures/science/recycle.texture"},
  },
  sign_icon = "textures/science/tech-cycle.texture",
}

prototype "生产甲烷" {
  desc = "生产工业气体甲烷",
  icon = "textures/science/tech-liquid.texture",
  type = { "tech", "task" },
  task = {"stat_production", 0, "甲烷"},
  prerequisites = {"碳处理2"},
  count = 1000,
  tips_pic = {
    "textures/task_tips_pic/task_produce_ch4.texture",
  },
  sign_desc = {
    { desc = "用化工厂生产1000个单位甲烷", icon = "textures/fluid/gas.texture"},
  },
}

prototype "生产塑料" {
  desc = "使用有机化学的科学成果生产质量轻、耐腐蚀的工业材料塑料",
  icon = "textures/construct/assembler.texture",
  type = { "tech", "task" },
  task = {"stat_production", 0, "塑料"},
  prerequisites = {"有机化学"},
  count = 30,
  tips_pic = {
    "textures/task_tips_pic/task_produce_plastic.texture",
  },
  sign_desc = {
    { desc = "生产30个塑料", icon = "textures/construct/assembler.texture"},
  },
}

prototype "电磁学1" {
  desc = "研究电能转换成机械能的基础供能装置",
  type = { "tech" },
  icon = "textures/science/tech-equipment.texture",
  effects = {
    unlock_recipe = {"电动机1"},
  },
  prerequisites = {"生产塑料","基地生产2","排放"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
  },
  count = 10,
  time = "6s"
}

--研究机械科技瓶
prototype "机械研究" {
  desc = "对适合在火星表面作业的机械装置进行改进和开发",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"机械科技包1"},
  },
  prerequisites = {"电磁学1"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
  },
  count = 6,
  time = "2s",
  sign_desc = {
    { desc = "该科技是火星探索的前沿科技，它可以引导更多的科技研究", icon = "textures/science/important.texture"},
  },
  sign_icon = "textures/science/tech-important.texture",
}

prototype "蒸馏1" {
  desc = "科技的描述",
  type = { "tech" },
  icon = "textures/science/tech-chemical.texture",
  effects = {
    unlock_recipe = {"蒸馏厂1"},
  },
  prerequisites = {"机械研究"},
  ingredients = {
    {"气候科技包", 1},
    {"机械科技包", 1},
  },
  count = 4,
  time = "2s"
}

prototype "挖掘1" {
  desc = "科技的描述",
  type = { "tech" },
  icon = "textures/science/tech-manufacture.texture",
  effects = {
    unlock_recipe = {"采矿机1"},
  },
  prerequisites = {"机械研究"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
  },
  count = 4,
  time = "2s"
}

prototype "驱动1" {
  desc = "科技的描述",
  type = { "tech" },
  icon = "textures/science/tech-manufacture.texture",
  effects = {
    unlock_recipe = {"机器爪1"},
  },
  prerequisites = {"机械研究"},
  ingredients = {
    {"机械科技包", 1},
  },
  count = 3,
  time = "3s"
}

prototype "电力传输1" {
  desc = "科技的描述",
  type = { "tech" },
  icon = "textures/science/tech-manufacture.texture",
  effects = {
    unlock_recipe = {"铁制电线杆"},
  },
  prerequisites = {"机械研究"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
  },
  count = 2,
  time = "6s"
}

prototype "物流1" {
  desc = "科技的描述",
  type = { "tech" },
  icon = "textures/science/tech-logistics.texture",
  effects = {
    unlock_recipe ={"车站1","物流中心1","运输车辆1"},
  },
  prerequisites = {"机械研究"},
  ingredients = {
    {"机械科技包", 1},
  },
  count = 5,
  time = "2s"
}

prototype "泵系统1" {
  desc = "科技的描述",
  type = { "tech" },
  icon = "textures/science/tech-manufacture.texture",
  effects = {
    unlock_recipe = {"压力泵1"},
  },
  prerequisites = {"机械研究"},
  ingredients = {
    {"气候科技包", 1},
    {"机械科技包", 1},
  },
  count = 4,
  time = "2s"
}

prototype "自动化1" {
  desc = "科技的描述",
  type = { "tech" },
  icon = "textures/science/tech-manufacture.texture",
  effects = {
    unlock_recipe = {"组装机1"},
  },
  prerequisites = {"驱动1","电力传输1"},
  ingredients = {
    {"机械科技包", 1},
  },
  count = 4,
  time = "3s"
}

prototype "地下水净化" {
  desc = "科技的描述",
  type = { "tech" },
  icon = "textures/science/tech-chemical.texture",
  effects = {
    unlock_recipe = {"地下卤水净化"},
  },
  prerequisites = {"蒸馏1"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
  },
  count = 4,
  time = "2.5s"
}

prototype "炼钢" {
  desc = "科技的描述",
  type = { "tech" },
  icon = "textures/science/tech-chemical.texture",
  effects = {
    unlock_recipe = {"钢板1"},
  },
  prerequisites = {"挖掘1"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
  },
  count = 4,
  time = "2.5s"
}

prototype "发电机1" {
  desc = "科技的描述",
  type = { "tech" },
  icon = "textures/science/tech-chemical.texture",
  effects = {
    unlock_recipe = {"蒸汽发电机1"},
  },
  prerequisites = {"电力传输1"},
  ingredients = {
    {"气候科技包", 1},
    {"机械科技包", 1},
  },
  count = 4,
  time = "2s"
}

prototype "空气过滤" {
  desc = "科技的描述",
  type = { "tech" },
  icon = "textures/science/tech-chemical.texture",
  effects = {
    unlock_recipe = {"空气过滤器1"},
  },
  prerequisites = {"泵系统1","发电机1"},
  ingredients = {
    {"气候科技包", 1},
  },
  count = 5,
  time = "2s"
}

prototype "矿物处理1" {
  desc = "科技的描述",
  type = { "tech" },
  icon = "textures/science/tech-chemical.texture",
  effects = {
    unlock_recipe = {"粉碎机1"},
  },
  prerequisites = {"挖掘1","自动化1"},
  ingredients = {
    {"地质科技包", 1},
    {"机械科技包", 1},
  },
  count = 5,
  time = "2s"
}