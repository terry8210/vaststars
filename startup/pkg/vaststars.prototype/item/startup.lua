local entities = {
    {
        prototype_name = "指挥中心",
        dir = "N",
        x = 126,
        y = 120,
        items = {
            {"物流中心I",1},
            {"铁制电线杆",20},
            {"砖石公路-X型-01",100},
            {"物流派送站", 100},
            {"小铁制箱子I", 100},
        },
    },
    {
        prototype_name = "组装机残骸",
        dir = "N",
        items = {
	        {"水电站I",1},
	        {"蒸馏厂I",1},
            {"电解厂I",1},
            {"地下水挖掘机",1},
            {"空气过滤器I",3},
            {"液罐I",6},
            {"太阳能板I",6},
            {"蓄电池I",4},
        },
        x = 111,
        y = 129,
    },
    {
        prototype_name = "抽水泵残骸",
        dir = "S",
        items = {
            {"破损水电站",1},
	        {"破损电解厂",1},
	        {"破损化工厂",4},
	        {"破损组装机",3},
	        {"破损铁制电线杆",15},
            {"破损太阳能板",10},
            {"破损蓄电池",6},
            {"破损空气过滤器",3},
            {"破损地下水挖掘机",2},
            {"破损物流中心",6},
            {"破损运输车辆",15},
        },
        x = 120,
        y = 126,
    },
    {
        prototype_name = "排水口残骸",
        dir = "S",
        items = {
            {"科研中心I",1},
            {"采矿机I",4},
            {"组装机I",4},
            {"熔炼炉I",2},
            {"运输车辆I",4},
        },
        x = 133,
        y = 122,
    },
}

local road = {
    {
        prototype_name = "砖石公路-U型-01",
        dir = "N",
        x = 116,
        y = 139,
    },
    {
        prototype_name = "砖石公路-I型-01",
        dir = "N",
        x = 116,
        y = 138,
    },
    {
        prototype_name = "砖石公路-I型-01",
        dir = "N",
        x = 116,
        y = 137,
    },
    {
        prototype_name = "砖石公路-I型-01",
        dir = "N",
        x = 116,
        y = 136,
    },
    {
        prototype_name = "砖石公路-I型-01",
        dir = "N",
        x = 116,
        y = 135,
    },
    {
        prototype_name = "砖石公路-I型-01",
        dir = "N",
        x = 116,
        y = 134,
    },
    {
        prototype_name = "砖石公路-I型-01",
        dir = "N",
        x = 116,
        y = 133,
    },
    {
        prototype_name = "砖石公路-I型-01",
        dir = "N",
        x = 116,
        y = 132,
    },
    {
        prototype_name = "砖石公路-I型-01",
        dir = "N",
        x = 116,
        y = 131,
    },
    {
        prototype_name = "砖石公路-I型-01",
        dir = "N",
        x = 116,
        y = 130,
    },
    {
        prototype_name = "砖石公路-I型-01",
        dir = "N",
        x = 116,
        y = 129,
    },
    {
        prototype_name = "砖石公路-I型-01",
        dir = "N",
        x = 116,
        y = 128,
    },
    {
        prototype_name = "砖石公路-I型-01",
        dir = "N",
        x = 116,
        y = 127,
    },
    {
        prototype_name = "砖石公路-I型-01",
        dir = "N",
        x = 116,
        y = 126,
    },
    {
        prototype_name = "砖石公路-L型-01",
        dir = "E",
        x = 116,
        y = 125,
    },
    {
        prototype_name = "砖石公路-U型-01",
        dir = "W",
        x = 117,
        y = 125,
    },
    {
        prototype_name = "砖石公路-U型-01",
        dir = "E",
        x = 120,
        y = 125,
    },
    {
        prototype_name = "砖石公路-I型-01",
        dir = "E",
        x = 121,
        y = 125,
    },
    {
        prototype_name = "砖石公路-I型-01",
        dir = "E",
        x = 122,
        y = 125,
    },
    {
        prototype_name = "砖石公路-I型-01",
        dir = "E",
        x = 123,
        y = 125,
    },
    {
        prototype_name = "砖石公路-I型-01",
        dir = "E",
        x = 124,
        y = 125,
    },
    {
        prototype_name = "砖石公路-I型-01",
        dir = "E",
        x = 125,
        y = 125,
    },
    {
        prototype_name = "砖石公路-I型-01",
        dir = "E",
        x = 126,
        y = 125,
    },
    {
        prototype_name = "砖石公路-I型-01",
        dir = "E",
        x = 127,
        y = 125,
    },
    {
        prototype_name = "砖石公路-I型-01",
        dir = "E",
        x = 128,
        y = 125,
    },
    {
        prototype_name = "砖石公路-I型-01",
        dir = "E",
        x = 129,
        y = 125,
    },
    {
        prototype_name = "砖石公路-I型-01",
        dir = "E",
        x = 130,
        y = 125,
    },
    {
        prototype_name = "砖石公路-I型-01",
        dir = "E",
        x = 131,
        y = 125,
    },
    {
        prototype_name = "砖石公路-U型-01",
        dir = "W",
        x = 132,
        y = 125,
    },
    {
        prototype_name = "砖石公路-U型-01",
        dir = "E",
        x = 135,
        y = 125,
    },
    {
        prototype_name = "砖石公路-I型-01",
        dir = "E",
        x = 136,
        y = 125,
    },
    {
        prototype_name = "砖石公路-I型-01",
        dir = "E",
        x = 137,
        y = 125,
    },
    {
        prototype_name = "砖石公路-I型-01",
        dir = "E",
        x = 138,
        y = 125,
    },
    {
        prototype_name = "砖石公路-T型-01",
        dir = "S",
        x = 139,
        y = 125,
    },
    {
        prototype_name = "砖石公路-I型-01",
        dir = "E",
        x = 140,
        y = 125,
    },
    {
        prototype_name = "砖石公路-I型-01",
        dir = "E",
        x = 141,
        y = 125,
    },
    {
        prototype_name = "砖石公路-I型-01",
        dir = "E",
        x = 142,
        y = 125,
    },
    {
        prototype_name = "砖石公路-I型-01",
        dir = "E",
        x = 143,
        y = 125,
    },
    {
        prototype_name = "砖石公路-I型-01",
        dir = "E",
        x = 144,
        y = 125,
    },
    {
        prototype_name = "砖石公路-I型-01",
        dir = "E",
        x = 145,
        y = 125,
    },
    {
        prototype_name = "砖石公路-I型-01",
        dir = "E",
        x = 146,
        y = 125,
    },
    {
        prototype_name = "砖石公路-I型-01",
        dir = "E",
        x = 147,
        y = 125,
    },
    {
        prototype_name = "砖石公路-I型-01",
        dir = "E",
        x = 148,
        y = 125,
    },
    {
        prototype_name = "砖石公路-U型-01",
        dir = "W",
        x = 149,
        y = 125,
    },
    {
        prototype_name = "砖石公路-I型-01",
        dir = "N",
        x = 139,
        y = 124,
    },
    {
        prototype_name = "砖石公路-I型-01",
        dir = "N",
        x = 139,
        y = 123,
    },
    {
        prototype_name = "砖石公路-I型-01",
        dir = "N",
        x = 139,
        y = 122,
    },
    {
        prototype_name = "砖石公路-I型-01",
        dir = "N",
        x = 139,
        y = 121,
    },
    {
        prototype_name = "砖石公路-I型-01",
        dir = "N",
        x = 139,
        y = 120,
    },
    {
        prototype_name = "砖石公路-I型-01",
        dir = "N",
        x = 139,
        y = 119,
    },
    {
        prototype_name = "砖石公路-I型-01",
        dir = "N",
        x = 139,
        y = 118,
    },
    {
        prototype_name = "砖石公路-I型-01",
        dir = "N",
        x = 139,
        y = 117,
    },
    {
        prototype_name = "砖石公路-I型-01",
        dir = "N",
        x = 139,
        y = 116,
    },
    {
        prototype_name = "砖石公路-I型-01",
        dir = "N",
        x = 139,
        y = 115,
    },
    {
        prototype_name = "砖石公路-I型-01",
        dir = "N",
        x = 139,
        y = 114,
    },
    {
        prototype_name = "砖石公路-I型-01",
        dir = "N",
        x = 139,
        y = 113,
    },
    {
        prototype_name = "砖石公路-I型-01",
        dir = "N",
        x = 139,
        y = 112,
    },
    {
        prototype_name = "砖石公路-U型-01",
        dir = "S",
        x = 139,
        y = 111,
    },
}

return {
    entities = entities,
    road = road,
}