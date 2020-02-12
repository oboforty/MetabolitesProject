
pubchem <- function(fake = FALSE) {
  return(list(
    download_all = function() {
      print("download_all pubchem")
    },

    parse = function() {
      print("fake_metabolite pubchem")
    },

    download = function() {
      print("download pubchem")
    },

    fake = function() {
      print("fake pubchem")
    },

    query = function() {
      print("query pubchem")
    }
  ))
}
