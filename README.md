Usage:

Will dump the parsed message to STDOUT as .[tsv](https://en.wikipedia.org/wiki/Tab-separated_values)

```bash
./calls_parse.pl 1112223333 Calls/ > allmessages.tsv
```

To import into SQLite:

```bash
sqlite3 allmessages.db <<SQL
create table if not exists messages (date text primary key, diretion text, sender text, message text);
.mode tabs messages
.import allmessages.tsv messages
SQL
```
