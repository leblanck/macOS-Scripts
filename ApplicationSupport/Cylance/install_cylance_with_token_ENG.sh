#!/bin/sh
#!/bin/bash

echo PLACE_TOKEN_HERE > /private/tmp/Cylance/cyagent_install_token
echo VenueZone="VENUE-NAME" >> /private/tmp/Cylance/cyagent_install_token
sudo installer -pkg /private/tmp/Cylance/CylancePROTECT.pkg -target /

exit 0
