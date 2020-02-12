
chemspider <- function(fake = FALSE) {
  return(list(
    download_all = function() {
      print("download_all chemspider")
    },

    parse = function() {
      print("fake_metabolite chemspider")
    },

    download = function() {
      print("download chemspider")
    },

    fake = function() {
      print("fake chemspider")
    },

    query = function() {
      print("query chemspider")
    }
  ))
}
