

## Functions

pi_order <- function(order){
  sapply(order, FUN = function(x) {
    return(
      switch(x,
             "Histosols" = 14,
             "Mollisols" = 13,
             "Vertisols" = 12,
             "Andisols" = 11,
             "Alfisols" = 10,
             "Inceptisols" = 9,
             "Gelisols" = 8,
             "Spodosols" = 7,
             "Entisols" = 6,
             "Aridisols" = 5,
             "Ultisols" = 4,
             "Oxisols" = 3
      )
    )
  }
  )
}


#GET SUBORDER**************************************************************************************


pi_suborder_mod <- function(order, suborder) {# come back to this - string match,
 # browser()
  # set possible suborder modifiers for the given order
  if (is.na(order)) {
    return(0)
  }
  if (is.na(suborder)) {
    return(0)
  }
  else {
    suborder_modifiers <- switch (order,
                                  "Inceptisols" = paste("And", "Gel", "Anthr", "Umb", sep = "|"),
                                  "Spodosols" = paste("Gel", "Hum", sep = "|"),
                                  "Gelisols" = "Hist",
                                  "Aridisols" = paste("Arg", "Calc", "Dur", sep = "|"),
                                  "Andisols" = "Vitr",
                                  "Entisols" = paste("Fluv", "Psamm", sep = "|"),
                                  "Mollisols" = paste("Rend", "Psamm", sep = "|")
    )
    # create regex statement to extract suborder modifiers for the given order
    rgx <- paste0("(^(", suborder_modifiers, ").*)")
    if (is.null(suborder_modifiers)) {
      return(0)
    }

    # check if given suborder is in list of possible modifiers
    suborder_modifier <- stringr::str_match(suborder, rgx)[[3]] ## why 3?

    if(is.na(suborder_modifier)) {
      return (0)
    }
    else if (!is.na(suborder_modifier))
    # set score modification
      mod <- switch(suborder_modifier,
                    "And" = 2,
                    "Gel" = 2,
                    "Hist" = 2,
                    "Hum" = 2,
                    "Anthr" = 1,
                    "Arg" = 1,
                    "Calc" = 1,
                    "Fluv" = 1,
                    "Rend" = 1,
                    "Umb" = 1,
                    "Vitr" = 1,
                    "Dur" = -1,
                    "Psamm" = -2)
    return(mod)
  }
}


#GET GREAT GROUP*********************************************************************************


pi_grtgrp_mod <- function(grtgrp) { # come back to this - string match,
  #browser()
  # set possible suborder modifiers for the given order
  pattern <- paste(
    "And", "Gel", "Hist", "Hum", "Eutr", "Moll", "Plagg", "Anthr", "Arg", "Calc",
    "Calci", "Fluv", "Umbr", "Vitr", "Melan", "Somb", "Verm", "Dur", "Acr", "Fragi",
    "Fragloss", "Hal", "Kand", "Kan", "Natr", "Na", "Palc", "Petr", "Plac", "Plinth",
    "Sal", "Sphagn", "Sulf", "Dur", "Psamm", "Dystr", "Nadur", "Quartz", sep = "|")

  rgx <- paste0("(^(", pattern, ").*)")

  grtgrp_sub <- stringr::str_match(grtgrp, rgx)[,3] #??

  if (is.na(grtgrp_sub) == F) {
    mod <- switch (grtgrp_sub,
                   "And" = 2, "Gel" = 2,
                   "Hist" = 2, "Hum" = 2,
                   "Eutr" = 2, "Moll" = 2,
                   "Plagg" = 2,
                   "Anthr" = 1, "Arg" = 1, "Calc" = 1,
                   "Calci" = 1, "Fluv" = 1, "Umbr" = 1,
                   "Vitr" = 1, "Melan" = 1, "Somb" = 1,
                   "Verm" = 1,
                   "Dur" = -1, "Acr"= -1, "Fragi" = -1,
                   "Fragloss" = -1, "Hal" = -1, "Kand" = -1,
                   "Kan" = -1, "Natr" = -1, "Na" = -1,
                   "Palc" = -1, "Petr" = -1, "Plac" = -1,
                   "Plinth" = -1, "Sal" = -1, "Sphagn" = -1,
                   "Sulf" = -1,
                   "Dur" = -2, "Psamm" = -2, "Dystr" = -2,
                   "Nadur" = -2, "Quartz" = -2)
  } else { mod <- 0}
  mod
}

#GET SUBGROUP*********************************************************************************
pi_subgrp_mod <- function(subgrp) { # come back to this - string match,
  #browser()
  # set possible suborder modifiers for the given order
  pattern <- paste(
    "Andaqueptic", "Andeptic", "Andic", "Aquandic", "Haploxerandic",
    "Udanic", "Ustandic", "Ustivitrandic", "Vitrandic", "Vitric",
    "Vitritorrandic", "Vitrixerandic",

    "Aquollic", "Borollic", "Calcixerollic", "Hapludollic", "Haploxerollic",
    "Haplustollic", "Mollic", "Rendollic", "Udollic", "Ustollic", "Xerollic",

    "Calciargidic", "Calcic", "Calcidic", "Calciorthidic", "Haplocalcidic",
    "Plagganthreptic", "Pachic",
    "Humic", "Humaqueptic",
    "Histic", "Ruptic-Histic",
    "Aquertic", "Ruptic-Verte", "Udertic", "Ustertic", "Vertic",
    "Alfic", "Aqualfic", "Argiarquic", "Argic", "Ardigic",
    "Boralfic", "Haplargidic", "Haploxeralfic", "Ruptic-Alfic",
    "Ruptic-Argic", "Ustalfic", "Xeralfic",
    "Anthraquic", "Anthropic",
    "Cumulic",
    "Fluvaquentic", "Fluventic", "Torrifluventic",
    "Udifluventic", "Ustifluventic",
    "Lamellic",

    "Sombric",
    "Thapto-Histic",
    "Umbric",
    "Vermic",
    "Durixerollic",
    "Acraquoxic", "Acrudoxic", "Acrustoxic", "Albaquultic",
    "Aquultic", "Orthoxic", "Oxic", "Ruptic-Ultic",
    "Torroxic", "Udoxic", "Ultic", "Ustoxic",
    "Alic",
    "Arenic",
    "Duric", "Duridic", "Durinodie", "Durorthidic",
    "Haploduridic", "Petronodic",
    "Fragiaquic", "Fragic",
    "Halic",

    "Kandic", "Kanhaplic",
    "Natric",
    "Placic",
    "Plinthaquic", "Plinthic",
    "Ruptic-Lithie", "Ruptic-Lithic-Entic", "Ruptic-Lithic-Xerochreptic",
    "Salic", "Salidic", "Salorthidic",
    "Sodic",
    "Sphagnic",
    "Sulfaqueptic", "Sulfic", "Sulfuric",
    "Dystric", "Grossarenic",
    "Lithic",
    "Petrocalcic", "Petrocalcidic",
    "Petroferric", "Petrogypsic",
    "Psammentic", "Torripsammentic", "Psammaquentic", "Quartzipsammentic",
    sep = "|")

  rgx <- paste0("(^(", pattern, ").*)")

  grtgrp_sub <- stringr::str_match(subgrp, rgx)[[3]]

  if (!is.na(grtgrp_sub)) {
    mod <- switch (grtgrp_sub,
                   "Andaqueptic" = 2,"Andeptic" = 2, "Andic" = 2,
                   "Aquandic" = 2, "Haploxerandic" = 2,
                   "Udanic" = 2, "Ustandic" = 2, "Ustivitrandic" = 2,
                   "Vitrandic" = 2, "Vitric" = 2,
                   "Vitritorrandic" = 2, "Vitrixerandic" = 2,

                   "Aquollic" = 2, "Borollic" = 2, "Calcixerollic" = 2,
                   "Hapludollic" = 2, "Haploxerollic" = 2,
                   "Haplustollic" = 2, "Mollic" = 2, "Rendollic" = 2,
                   "Udollic" = 2, "Ustollic" = 2, "Xerollic" = 2,

                   "Calciargidic" = 2, "Calcic" = 2, "Calcidic" = 2,
                   "Calciorthidic" = 2, "Haplocalcidic" = 2,
                   "Plagganthreptic" = 2, "Pachic" = 2,
                   "Humic" = 2, "Humaqueptic" = 2,
                   "Histic" = 2, "Ruptic-Histic" = 2,
                   "Aquertic" = 2, "Ruptic-Verte" = 2, "Udertic" = 2,
                   "Ustertic" = 2, "Vertic" = 2,

                   "Alfic" = 1, "Aqualfic" = 1, "Argiarquic" = 1,
                   "Argic" = 1, "Ardigic" = 1, "Boralfic" = 1,
                   "Haplargidic" = 1, "Haploxeralfic" = 1, "Ruptic-Alfic" = 1,
                   "Ruptic-Argic" = 1, "Ustalfic" = 1, "Xeralfic" = 1,
                   "Anthraquic" = 1, "Anthropic" = 1,
                   "Cumulic" = 1,
                   "Fluvaquentic" = 1, "Fluventic" = 1, "Torrifluventic" = 1,
                   "Udifluventic" = 1, "Ustifluventic" = 1,
                   "Lamellic" = 1,

                   "Sombric" = 1,
                   "Thapto-Histic" = 1,
                   "Umbric" = 1,
                   "Vermic" = 1,

                   "Durixerollic" = -1,
                   "Acraquoxic" = -1, "Acrudoxic" = -1, "Acrustoxic" = -1,
                   "Albaquultic" = -1, "Aquultic" = -1, "Orthoxic" = -1,
                   "Oxic" = -1, "Ruptic-Ultic" = -1, "Torroxic" = -1,
                   "Udoxic" = -1, "Ultic" = -1, "Ustoxic" = -1,
                   "Alic" = -1,
                   "Arenic" = -1,
                   "Duric" = -1, "Duridic" = -1, "Durinodie" = -1,
                   "Durorthidic" = -1,
                   "Haploduridic" = -1, "Petronodic" = -1,
                   "Fragiaquic" = -1, "Fragic" = -1,
                   "Halic" = -1,

                   "Kandic" = -1, "Kanhaplic" = -1,
                   "Natric" = -1,
                   "Placic" = -1,
                   "Plinthaquic" = -1, "Plinthic" = -1,
                   "Ruptic-Lithie" = -1, "Ruptic-Lithic-Entic" = -1,
                   "Ruptic-Lithic-Xerochreptic" = -1,
                   "Salic" = -1, "Salidic" = -1, "Salorthidic" = -1,
                   "Sodic" = -1,
                   "Sphagnic" = -1,
                   "Sulfaqueptic" = -1, "Sulfic" = -1, "Sulfuric" = -1,

                   "Dystric" = -2, "Grossarenic" = -2,
                   "Lithic" = -2,
                   "Petrocalcic" = -2, "Petrocalcidic" = -2,
                   "Petroferric" = -2, "Petrogypsic" = -2,
                   "Psammentic" = -2, "Torripsammentic" = -2,
                   "Psammaquentic" = -2, "Quartzipsammentic" = -2,
    )




  } else { mod <- 0}
  mod
}

#GET TAXCLASS NAME ************************************************************************

pi_taxclname = function(taxclname) {
  taxpattern = paste(
    "Very fine",
    "Fine",
    "Fine-loamy",
    "Fine-silty",
    "Sandy",
    "Coarse-loamy",
    "Coarse-silty",
    sep = "|"
  )

  #Find everything before
  rgx = paste0( "^(.+?)(?=,)")

  taxclname <- stringr::str_extract(taxclname, rgx)

  taxclname = dplyr::recode(taxclname,
                            "Very fine" = -1,
                            "Fine" = 0,
                            "Fine-loamy" = 1,
                            "Coarse-loamy" = 0,
                            "Sandy"= -2,
                            "Fine-silty" = 2,
                            "Coarse-silty" = 2,
                            "Coarse" = 0
  )

  #convert NA values (unmatched items) to 0.
  taxclname[is.na(taxclname)] <- 0

  #check
  ##taxclname
  return(taxclname)

}
