

pi_suborder_mod <- function(order, suborder) { # come back to this - string match,
  #browser()
  # set possible suborder modifiers for the given order
  suborder_modifiers <- switch (order,
    "Inceptisols" = paste("And", "Gel", "Anthr", "Umb", sep = "|"),
    "Spodosols" = paste("Gel", "Hum", sep = "|")
  )
  
  # create regex statement to extract suborder modifiers for the given order
  rgx <- paste0("(^(", suborder_modifiers, ").*)")
  
  # check if given suborder is in list of possible modifiers
  suborder_modifier <- stringr::str_match(suborder, rgx)[[3]]
  
  # set score modification
  if (!is.na(suborder_modifier)) {
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
  } else {
    mod <- 0
  }
  mod
}

pi_suborder_mod("Inceptisols", "Andepts")
pi_suborder_mod("Spodosols", "Gelods")
pi_suborder_mod("Spodosols", "Andepts")
      

