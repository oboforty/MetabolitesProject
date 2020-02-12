
kegg <- function(fake = FALSE) {
  return(list(
    download_all = function() {
      print("download_all kegg")
    },

    parse = function() {
      print("fake_metabolite kegg")
    },

    download = function() {
      print("download kegg")
    },

    fake = function() {
      print("fake kegg")
    },

    query = function() {
      print("query kegg")
    }
  ))
}
