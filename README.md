Usage:

Will dump the parsed message to STDOUT as .tsv

./calls_parse.pl 1112223333 Calls/ > allmessages.tsv

To import into SQLite:


create table if not exists test (date text primary key, diretion text, sender text, message text);
.mode tabs test
.import allmessages.tsv test
