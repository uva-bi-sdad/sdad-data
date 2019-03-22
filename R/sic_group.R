# Clean Mine material SIC name
sic_group <- function(sic) {
  switch(sic,
         "Coal (Bituminous)" = "Coal",
         "Crushed, Broken Limestone NEC" = "Lime",
         "Crushed, Broken Granite" = "Granite",
         "Crushed, Broken Traprock" = "Other",
         "Lime" = "Lime",
         "Crushed, Broken Stone NEC" = "Other",
         "Dimension Slate" = "Slate",
         "Cement" = "Cement",
         "Common Shale" = "Shale",
         "Dimension Granite" = "Granite",
         "Kyanite" = "Other",
         "Clay, Ceramic, Refractory Mnls." = "Other",
         "Crushed, Broken Slate" = "Slate",
         "Crushed, Broken Mica" = "Mica",
         "Crushed, Broken Sandstone" = "Sandstone",
         "Construction Sand and Gravel" = "Sand",
         "Pigment Minerals" = "Other",
         "Aplite" = "Other",
         "Dimension Quartzite" = "Quartzite",
         "Talc" = "Other",
         "Coal (Anthracite)" = "Coal",
         "Vermiculite" = "Other",
         "Crushed, Broken Quartzite" = "Quartzite",
         "Sand, Common" = "Sand",
         "Gemstones" = "Other",
         "Dimension Limestone" = "Lime",
         "Dimension Stone NEC",
         "Titanium Ore" = "Titanium",
         "Soapstone, Crushed Dimension" = "Soapstone")
}





