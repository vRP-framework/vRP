
-- this file is used to define additional static blips and markers to the map
-- some lists: https://wiki.gtanet.work/index.php?title=Blips

local cfg = {}

-- list of blips
-- {x,y,z,idtype,idcolor,text}
cfg.blips = {
  {-1202.96252441406,-1566.14086914063,4.61040639877319,311,17,"Body training"},
  {-2176.01196289063,-37.3997116088867,70.1904525756836,85,47,"Peaches field"},
  {-1484.080078125,-397.131927490234,38.3666610717773,85,47,"Peaches resale"},
  {123.05940246582,3336.2939453125,30.7280216217041,85,5,"Gold deposit"},
  {-75.9527359008789,6495.42919921875,31.4908847808838,85,5,"Gold processing"},
  {1032.71105957031,2516.86010742188,46.6488876342773,85,5,"Gold refinement"},
  {-139.963653564453,-823.515258789063,31.4466247558594,85,5,"Gold resale"}
}

-- list of markers
-- {x,y,z,sx,sy,sz,r,g,b,a,visible_distance}
cfg.markers = {
}

return cfg
