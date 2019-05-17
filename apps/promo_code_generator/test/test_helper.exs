ExUnit.start()

# Load all the non compiled files to allow other applications to use them
"lib/safe_boda/promo_code/"
|> Path.join("**/*.exs")
|> Path.wildcard()
|> Enum.each(&Code.load_file/1)
