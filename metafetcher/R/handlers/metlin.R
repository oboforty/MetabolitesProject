
metlin <- function(fake = FALSE) {
  return(list(
    download_all = function() {
      print("download_all metlin")
    },

    parse = function() {
      print("fake_metabolite metlin")
    },

    download = function() {
      print("download metlin")
    },

    fake = function() {
      print("fake metlin")
    },

    query = function() {
      print("query metlin")
    }
  ))
}
