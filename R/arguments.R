ShellArgumentsBuilder <- function(gcloud) {

  .arguments <- character()

  # define the builder
  builder <- function(...) {

    dots <- list(...)

    # return arguments when nothing supplied
    if (length(dots) == 0)
      return(.arguments)

    # any 0-length entries imply we should ignore this
    n <- lapply(dots, length)
    if (any(n == 0))
      return(invisible(builder))

    # convert job objects into ids
    dots <- lapply(dots, function(dot) {
      if (inherits(dot, "cloudml_job"))
        return(dot$id)
      dot
    })

    # flatten a potentially nested list
    flattened <- flatten_list(dots)
    if (length(flattened) == 0)
      return(.arguments)

    formatted <- do.call(sprintf, flattened)
    .arguments <<- c(.arguments, formatted)
    invisible(builder)
  }

  # prepend project + account information
  conf <- gcloud_config(gcloud = gcloud)

  if (!is.null(conf[["account"]])) {
    (builder
     ("--account")
     (conf[["account"]]))
  }

  if (!is.null(conf[["project"]])) {
    (builder
      ("--project")
      (conf[["project"]]))
  }

  if (!is.null(conf[["configuration"]])) {
    (builder
       ("--configuration")
       (conf[["configuration"]]))
  }

  # return our builder object
  builder
}

MLArgumentsBuilder <- function(gcloud) {
  (ShellArgumentsBuilder(gcloud)
   ("ml-engine"))
}
