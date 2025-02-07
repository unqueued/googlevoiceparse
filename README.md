
This is a parser that will convert a Google Exports Voice archive into a TSV

## Usage

Requires the [Mojo::DOM](https://metacpan.org/pod/Mojo::DOM)

Install required dependencies with cpanm:

```shell
cpanm --installdeps .
```

Will dump the parsed message to STDOUT as .[tsv](https://en.wikipedia.org/wiki/Tab-separated_values)

```bash
./calls_parse.pl 1112223333 Calls/ > allmessages.tsv
```
Where 1112223333 is your phone number.

To import into SQLite:

```bash
sqlite3 allmessages.db <<SQL
create table if not exists messages (date text, diretion text, sender text, message text);
.mode tabs messages
.import allmessages.tsv messages
SQL
```

## TODO

- [ ] Comment more
- [ ] Refactor to be a cleaner FSM
- [x] Convert HTML entities to their ASCII or Unicode equivilents, like ```&#39;```

As of 2020-02-10, parser still works.
