local DEFINE = {
    FRAMES_PER_SECOND = 60,
    ROAD_YAXIS_DEFAULT = 2.2, -- 路面高度 -- todo 建议移至编辑器配置
    ROAD_WIDTH = 0.6, -- 路面宽度
}

DEFINE.ROAD_ARROW_YAXIS_DEFAULT = DEFINE.ROAD_YAXIS_DEFAULT + 0.03 -- 路面箭头高度
DEFINE.FRAME_INTERVAL_MS = 1000 / DEFINE.FRAMES_PER_SECOND
DEFINE.FRAME_INTERVAL = math.floor(DEFINE.FRAME_INTERVAL_MS / 10)
return DEFINE