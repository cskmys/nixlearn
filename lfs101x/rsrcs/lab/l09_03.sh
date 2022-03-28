#!/bin/bash
SC=/tmp/datestamp.sh
OP=/tmp/datestamp
echo -e "#!/bin/bash\ndate > $OP" > $SC
chmod +x $SC
ls -l /tmp/datestamp*
at now +1 minute -f $SC
atq
echo "wait a min"
sleep 65
ls -l /tmp/datestamp*
cat $OP
rm $SC
rm $OP
ls -l /tmp/datestamp*