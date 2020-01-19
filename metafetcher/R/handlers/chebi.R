
chebi <- function(fake = FALSE) {
  return(list(
    download_all = function() {
      print("download_all chebi")
    },

    parse = function() {
      print("fake_metabolite chebi")
    },

    download = function() {
      print("download chebi")
    },

    fake = function() {
      print("fake chebi")
    },

    query = function() {
      print("query chebi")
    }
  ))
}
