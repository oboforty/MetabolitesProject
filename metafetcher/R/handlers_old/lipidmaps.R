
lipidmaps <- function(fake = FALSE) {
  return(list(
    download_all = function() {
      print("download_all lipidmaps")
    },

    parse = function() {
      print("fake_metabolite lipidmaps")
    },

    download = function() {
      print("download lipidmaps")
    },

    fake = function() {
      print("fake lipidmaps")
    },

    query = function() {
      print("query lipidmaps")
    }
  ))
}
