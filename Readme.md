# SetUp

Prepare for setup multiple instance , currently use ansible to manage remote server.


```bash
./start.sh --init  # create instances
./start.sh -s xxip #  ssh to server
./start.sh -m modfilename otherargs # run script on remote and with customer args

./start.sh --destroy # destroy instances
```