# ToDo

- Move "MagicCardsRetriever#call_mtg_api" to a new class acting as an API wrapper.
- Use of DockerCompose.
- Move CLI commands to a Make file.

----------

# Original exercise statement

Using *only* the https://api.magicthegathering.io/v1/cards endpoint from the Magic the Gathering API, create a command-line tool that:

* Returns a list of *Cards* grouped by *Set*.
* Returns a list of *Cards* grouped by *Set* and then by *`rarity`*.
* Returns a list of cards from the  *Khans of Tarkir* that ONLY have the colors *red and blue*.

## Environment

* You can use any one of the following programming languages: JavaScript, Elixir, Python, Ruby, Go, C, Crystal, Swift, Obj-C.

## Limitations

* You are *not* allowed to use a third-party library that wraps the MTG API.
* You can only use the https://api.magicthegathering.io/v1/cards endpoint.

## Bonus points for...

* Using only the programming language's standard library.
* Parallelising the retrieval of *Cards*  to speed up things.
* Respecting the API's Rate Limiting facilities.
* Writing tests.
