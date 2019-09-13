myinput = load 'hdfs://localhost:9000/user/hadoop/warehouse/shakespearehamlet.txt' USING TextLoader() as (myword:chararray);
words = FOREACH myinput GENERATE FLATTEN(TOKENIZE(LOWER(*)));
grouped = GROUP words BY $0;
counts = FOREACH grouped GENERATE group, COUNT(words);
counts = ORDER counts BY $1;
dump counts;

