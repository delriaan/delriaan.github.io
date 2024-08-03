web_server <- servr::httd(
  dir = getwd()
  # server_config() options ----
  , baseurl = getwd() |> fs::path_file()
  , port = parallelly::freePort()
  , browser = FALSE
  , daemon = TRUE
  )